# -*- coding: utf-8 -*-

from django.test import TestCase
from django.conf import settings
from weblate_web.data import VERSION, EXTENSIONS
import os


class ViewTestCase(TestCase):
    def test_index_redirect(self):
        response = self.client.get('/')
        self.assertRedirects(response, '/en/', 301)

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
