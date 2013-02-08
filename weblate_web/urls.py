# -*- coding: utf-8 -*-
#
# Copyright © 2012 - 2013 Michal Čihař <michal@cihar.com>
#
# This file is part of Weblate <http://weblate.org/>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

from django.conf.urls import patterns, include, url
from django.views.generic import TemplateView, RedirectView
from django.conf import settings
from django.contrib.sitemaps import Sitemap
from localeurl.templatetags.localeurl_tags import chlocale


class PagesSitemap(Sitemap):
    '''
    Sitemap of static pages for one language.
    This is heavily based on localeurl sitemap, but
    does not use get_absolute_url.
    '''
    def __init__(self, language):
        self.language = language

    def items(self):
        return (
            ('/', 1.0, 'weekly'),
            ('/features/', 0.9, 'weekly'),
            ('/tour/', 0.9, 'weekly'),
            ('/download/', 0.5, 'daily'),
            ('/try/', 0.5, 'weekly'),
            ('/hosting/', 0.8, 'weekly'),
            ('/contribute/', 0.7, 'weekly'),
            ('/support/', 0.7, 'weekly'),
        )

    def location(self, item):
        return chlocale(item[0], self.language)

    def priority(self, item):
        if self.language == 'en':
            return item[1]
        else:
            return item[1] * 3 / 4

    def changefreq(self, item):
        return item[2]

# create each section in all languages
sitemaps = {}

for lang in settings.LANGUAGES:
    sitemaps[lang[0]] = PagesSitemap(lang[0])

urlpatterns = patterns('',
    url(
        r'^$',
        TemplateView.as_view(template_name="index.html"),
        name='home'
    ),
    url(
        r'^features/$',
        TemplateView.as_view(template_name="features.html"),
        name='features'
    ),
    url(
        r'^tour/$',
        TemplateView.as_view(template_name="tour.html"),
        name='tour'
    ),
    url(
        r'^download/$',
        TemplateView.as_view(template_name="download.html"),
        name='download'
    ),
    url(
        r'^try/$',
        TemplateView.as_view(template_name="try.html"),
        name='try'
    ),
    url(
        r'^hosting/$',
        TemplateView.as_view(template_name="hosting.html"),
        name='hosting'
    ),
    url(
        r'^contribute/$',
        TemplateView.as_view(template_name="contribute.html"),
        name='contribute'
    ),
    url(
        r'^support/$',
        TemplateView.as_view(template_name="support.html"),
        name='support'
    ),

    # Compatibility with disabled languages
    url(
        r'^[a-z][a-z]/$',
        RedirectView.as_view(url='/')
    ),
    # Broken links
    url(
        r'^http:/.*$',
        RedirectView.as_view(url='/')
    ),
    url(
        r'^index\.html$',
        RedirectView.as_view(url='/')
    ),
    url(
        r'^[a-z][a-z]/index\.html$',
        RedirectView.as_view(url='/')
    ),

    url(
        r'^sitemap\.xml$',
        'django.contrib.sitemaps.views.sitemap',
        {'sitemaps': sitemaps}
    ),

    # Media files on devel server
    url(
        r'^media/(?P<path>.*)$',
        'django.views.static.serve',
        {'document_root': settings.MEDIA_ROOT}
    ),
)
