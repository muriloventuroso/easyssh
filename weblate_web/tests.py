# -*- coding: utf-8 -*-

import os
import shutil
import tempfile

from django.test import TestCase
from django.conf import settings
from django.test.utils import override_settings
from django.urls import reverse
from django.utils.translation import override

from wlhosted.data import SUPPORTED_LANGUAGES
from wlhosted.payments.models import Customer, Payment

from weblate_web.data import VERSION, EXTENSIONS
from weblate_web.templatetags.downloads import filesizeformat, downloadlink

TEST_DATA = os.path.join(os.path.dirname(__file__), 'test-data')


class ViewTestCase(TestCase):
    '''
    Views testing.
    '''
    def test_index_redirect(self):
        response = self.client.get('/')
        self.assertRedirects(response, '/en/', 302)

    def test_index_en(self):
        response = self.client.get('/en/')
        self.assertContains(response, 'See more features')

    def test_index_cs(self):
        response = self.client.get('/cs/')
        self.assertContains(response, u'Další vlastnosti')

    def test_index_be(self):
        response = self.client.get('/be/')
        self.assertContains(response, u'Больш функцый')

    def test_index_be_latin(self):
        response = self.client.get('/be@latin/')
        self.assertContains(response, u'Boĺš funkcyj')

    def test_terms(self):
        response = self.client.get('/en/terms/')
        self.assertContains(response, u'04705904')

    def test_download_en(self):
        # create dummy files for testing
        filenames = [
            'Weblate-{0}.{1}'.format(VERSION, ext) for ext in EXTENSIONS
        ]
        filenames.append('Weblate-test-{0}.tar.xz'.format(VERSION))

        temp_dir = tempfile.mkdtemp()

        try:
            with override_settings(FILES_PATH=temp_dir):
                for filename in filenames:
                    fullname = os.path.join(settings.FILES_PATH, filename)
                    with open(fullname, 'w') as handle:
                        handle.write('test')

                response = self.client.get('/en/download/')
                self.assertContains(response, 'Download Weblate')

        finally:
            shutil.rmtree(temp_dir)

    def test_sitemap(self):
        response = self.client.get('/sitemap.xml')
        self.assertContains(response, 'http://testserver/es/features/')


class UtilTestCase(TestCase):
    '''
    Helper code testing.
    '''
    def test_format(self):
        self.assertEqual(filesizeformat(0), '0 bytes')
        self.assertEqual(filesizeformat(1000), '1000 bytes')
        self.assertEqual(filesizeformat(1000000), '976.6 KiB')
        self.assertEqual(filesizeformat(1000000000), '953.7 MiB')
        self.assertEqual(filesizeformat(10000000000000), '9313.2 GiB')

    @override_settings(FILES_PATH=TEST_DATA)
    def test_downloadlink(self):
        self.assertIn(
            'Sources tarball, gzip compressed',
            downloadlink('foo.tar.gz')
        )
        self.assertIn(
            'Sources tarball, xz compressed',
            downloadlink('foo.tar.xz')
        )
        self.assertIn(
            'Sources tarball, bzip2 compressed',
            downloadlink('foo.tar.bz2')
        )
        self.assertIn(
            'Sources, zip compressed',
            downloadlink('foo.zip')
        )
        self.assertIn(
            '>foo.pdf (0 bytes)',
            downloadlink('foo.pdf')
        )
        self.assertIn(
            '>text (0 bytes)',
            downloadlink('foo.pdf', 'text')
        )


class PaymentsTest(TestCase):
    def test_languages(self):
        self.assertEqual(
            set(SUPPORTED_LANGUAGES),
            set([x[0] for x in settings.LANGUAGES]),
        )

    def create_payment(self):
        customer = Customer.objects.create(
            email='weblate@example.com',
            user_id=1,
            origin='/en/'
        )
        payment = Payment.objects.create(
            customer=customer,
            amount=100,
            description='Test payment',
        )
        return (
            payment,
            reverse('payment', kwargs={'pk': payment.pk}),
            reverse('payment-customer', kwargs={'pk': payment.pk}),
        )

    def test_view(self):
        with override('en'):
            payment, url, customer_url = self.create_payment()
            response = self.client.get(url, follow=True)
            self.assertRedirects(response, customer_url)
            self.assertContains(response, 'Please provide your billing')
            response = self.client.post(
                customer_url,
                {
                    'name': 'Michal Čihař',
                    'address': 'Zdiměřická 1439',
                    'city': '149 00 Praha 4',
                    'country': 'CZ',
                    'vat_0': 'CZ',
                    'vat_1': '8003280318',
                },
                follow=True
            )
            self.assertRedirects(response, url)
            self.assertContains(response, 'Test payment')
            self.assertContains(response, '121.0 EUR')
            return payment, url

    def check_payment(self, payment, state):
        fresh = Payment.objects.get(pk=payment.pk)
        self.assertEqual(fresh.state, state)

    @override_settings(PAYMENT_DEBUG=True)
    def test_pay(self):
        payment, url = self.test_view()
        response = self.client.post(url, {'method': 'pay'})
        self.assertRedirects(response, '/en/?payment={}'.format(payment.pk))
        self.check_payment(payment, Payment.ACCEPTED)

    @override_settings(PAYMENT_DEBUG=True)
    def test_reject(self):
        payment, url = self.test_view()
        response = self.client.post(url, {'method': 'reject'})
        self.assertRedirects(response, '/en/?payment={}'.format(payment.pk))
        self.check_payment(payment, Payment.REJECTED)

    @override_settings(PAYMENT_DEBUG=True)
    def test_pending(self):
        payment, url = self.test_view()
        response = self.client.post(url, {'method': 'pending'})
        complete_url = reverse('payment-complete', kwargs={'pk': payment.pk})
        self.assertRedirects(
            response,
            'https://cihar.com/?url=http://testserver' + complete_url,
            fetch_redirect_response=False
        )
        self.check_payment(payment, Payment.PENDING)
        response = self.client.get(complete_url)
        self.assertRedirects(response, '/en/?payment={}'.format(payment.pk))
        self.check_payment(payment, Payment.ACCEPTED)
