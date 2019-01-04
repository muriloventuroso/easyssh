# -*- coding: utf-8 -*-

import os
import shutil
import tempfile

from dateutil.relativedelta import relativedelta

from django.conf import settings
from django.contrib.auth.models import User
from django.core.management import call_command
from django.test import TestCase
from django.test.utils import override_settings
from django.urls import reverse
from django.utils import timezone
from django.utils.translation import override

from wlhosted.data import SUPPORTED_LANGUAGES
from wlhosted.payments.models import Customer, Payment

from weblate_web.data import VERSION, EXTENSIONS
from weblate_web.models import Donation, Reward, PAYMENTS_ORIGIN
from weblate_web.templatetags.downloads import filesizeformat, downloadlink

TEST_DATA = os.path.join(os.path.dirname(__file__), 'test-data')
TEST_FAKTURACE = os.path.join(TEST_DATA, 'fakturace')


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
        self.assertEqual(
            'Sources tarball, gzip compressed',
            downloadlink('foo.tar.gz')['text']
        )
        self.assertEqual(
            'Sources tarball, xz compressed',
            downloadlink('foo.tar.xz')['text']
        )
        self.assertEqual(
            'Sources tarball, bzip2 compressed',
            downloadlink('foo.tar.bz2')['text']
        )
        self.assertEqual(
            'Sources, zip compressed',
            downloadlink('foo.zip')['text']
        )
        self.assertEqual(
            '0 bytes',
            downloadlink('foo.pdf')['size']
        )
        self.assertEqual(
            '0 bytes',
            downloadlink('foo.pdf', 'text')['size']
        )
        self.assertEqual(
            'text',
            downloadlink('foo.pdf', 'text')['text']
        )


class FakuraceTestCase(TestCase):
    def setUp(self):
        super().setUp()
        dirs = ('contacts', 'data', 'pdf', 'tex', 'config')
        for name in dirs:
            full = os.path.join(TEST_FAKTURACE, name)
            if not os.path.exists(full):
                os.makedirs(full)

    @staticmethod
    def create_payment():
        customer = Customer.objects.create(
            email='weblate@example.com',
            user_id=1,
            origin=PAYMENTS_ORIGIN,
        )
        payment = Payment.objects.create(
            customer=customer,
            amount=100,
            description='Test payment',
            backend='pay',
            recurring='y',
        )
        return (
            payment,
            reverse('payment', kwargs={'pk': payment.pk}),
            reverse('payment-customer', kwargs={'pk': payment.pk}),
        )


class PaymentsTest(FakuraceTestCase):
    def test_languages(self):
        self.assertEqual(
            set(SUPPORTED_LANGUAGES),
            {x[0] for x in settings.LANGUAGES},
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

    @override_settings(PAYMENT_DEBUG=True, PAYMENT_FAKTURACE=TEST_FAKTURACE)
    def test_pay(self):
        payment, url = self.test_view()
        response = self.client.post(url, {'method': 'pay'})
        self.assertRedirects(
            response,
            '{}?payment={}'.format(PAYMENTS_ORIGIN, payment.pk),
            fetch_redirect_response=False
        )
        self.check_payment(payment, Payment.ACCEPTED)

    @override_settings(PAYMENT_DEBUG=True)
    def test_reject(self):
        payment, url = self.test_view()
        response = self.client.post(url, {'method': 'reject'})
        self.assertRedirects(
            response,
            '{}?payment={}'.format(PAYMENTS_ORIGIN, payment.pk),
            fetch_redirect_response=False
        )
        self.check_payment(payment, Payment.REJECTED)

    @override_settings(PAYMENT_DEBUG=True, PAYMENT_FAKTURACE=TEST_FAKTURACE)
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
        self.assertRedirects(
            response,
            '{}?payment={}'.format(PAYMENTS_ORIGIN, payment.pk),
            fetch_redirect_response=False
        )
        self.check_payment(payment, Payment.ACCEPTED)


class DonationTest(FakuraceTestCase):
    credentials = {'username': 'testuser', 'password': 'testpassword'}

    def setUp(self):
        super().setUp()
        self.reward_link = Reward.objects.create(
            name='Link on thanks page', amount=666, recurring='y',
            has_link=True, third_party=False, thanks_link=True, active=True
        )
        self.reward = Reward.objects.create(
            name='Link in file', amount=66, recurring='y',
            has_link=True, third_party=False, thanks_link=False, active=True
        )
        self.secret_reward = Reward.objects.create(
            name='Secret link in file', amount=6666, recurring='y',
            has_link=True, third_party=True, thanks_link=False, active=True
        )

    def create_user(self):
        return User.objects.create_user(**self.credentials)

    def login(self):
        user = self.create_user()
        self.client.login(**self.credentials)
        return user

    def test_donate_page(self):
        response = self.client.get('/en/donate/')
        self.assertContains(response, '/donate/new/')
        self.login()

        # Check rewards on page
        response = self.client.get('/en/donate/new/')
        self.assertContains(response, self.reward.name)
        self.assertNotContains(response, self.secret_reward.name)

        # Check direct link to reward
        response = self.client.get(
            '/en/donate/new/{}/'.format(self.secret_reward.pk)
        )
        self.assertNotContains(response, self.reward.name)
        self.assertContains(response, self.secret_reward.name)

    def test_donation_process(self):
        user = self.login()
        # Create payment
        payment = self.create_payment()[0]
        payment.state = Payment.ACCEPTED
        payment.extra = {'reward': self.reward.pk}
        payment.save()
        payment.customer.origin = PAYMENTS_ORIGIN
        payment.customer.user_id = user.pk
        payment.customer.save()

        # Process it
        response = self.client.get(
            '/donate/process/',
            {'payment': payment.pk},
            follow=True
        )
        self.assertContains(response, 'Thank you for your donation.')

    def test_your_donations(self):
        # Check login link
        self.assertContains(
            self.client.get(reverse('donate')),
            '/sso-login/'
        )
        user = self.login()

        # No login/donations
        response = self.client.get(reverse('donate'))
        self.assertNotContains(response, '/sso-login/')
        self.assertNotContains(response, 'Your donations')

        # Donation show show up
        Donation.objects.create(
            reward=self.reward, user=user, active=True,
            expires=timezone.now() + relativedelta(years=1),
            payment=self.create_payment()[0].pk
        )
        self.assertContains(
            self.client.get(reverse('donate')),
            'Your donations'
        )

    def create_donation(self, years=1):
        return Donation.objects.create(
            reward=self.reward_link, user=self.create_user(),
            active=True,
            expires=timezone.now() + relativedelta(years=years),
            payment=self.create_payment()[0].pk,
            link_url='https://example.com/weblate',
            link_text='Weblate donation test',
        )

    def test_link(self):
        self.create_donation()
        response = self.client.get('/en/thanks/')
        self.assertContains(response, 'https://example.com/weblate')
        self.assertContains(response, 'Weblate donation test')

    @override_settings(PAYMENT_DEBUG=True, PAYMENT_FAKTURACE=TEST_FAKTURACE)
    def test_recurring(self):
        donation = self.create_donation(-1)
        self.assertEqual(donation.payment_obj.payment_set.count(), 0)
        # The processing fails here, but new payment is created
        call_command('process_donations')
        self.assertEqual(donation.payment_obj.payment_set.count(), 1)
        # Flag it as paid
        donation.payment_obj.payment_set.update(state=Payment.ACCEPTED)

        # Process pending payments
        call_command('process_donations')
        old = donation.expires
        donation.refresh_from_db()
        self.assertGreater(donation.expires, old)
