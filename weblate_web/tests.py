# -*- coding: utf-8 -*-

from django.test import TestCase
from django.conf import settings
from weblate_web.data import VERSION, EXTENSIONS
from weblate_web.templatetags.downloads import filesizeformat
import os


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

    def test_download_en(self):
        # create dummy files for testing
        filenames = ['weblate-%s.%s' % (VERSION, ext) for ext in EXTENSIONS]
        unlink = []

        if not os.path.exists(settings.FILES_PATH):
            os.makedirs(settings.FILES_PATH)

        for filename in filenames:
            fullname = os.path.join(settings.FILES_PATH, filename)
            if not os.path.exists(fullname):
                unlink.append(fullname)
                with open(fullname, 'w') as handle:
                    handle.write('test')

        response = self.client.get('/en/download/')
        self.assertContains(response, 'Download Weblate')

        for filename in unlink:
            os.unlink(filename)

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
