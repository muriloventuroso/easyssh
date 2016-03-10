# -*- coding: utf-8 -*-

import os
import shutil
import tempfile
from django.test import TestCase
from django.conf import settings
from django.test.utils import override_settings
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

    def test_download_en(self):
        # create dummy files for testing
        filenames = ['Weblate-%s.%s' % (VERSION, ext) for ext in EXTENSIONS]
        filenames.append('Weblate-test-%s.tar.xz' % VERSION)

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
            print temp_dir
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
