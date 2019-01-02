# -*- coding: utf-8 -*-
#
# Copyright © 2012 - 2019 Michal Čihař <michal@cihar.com>
#
# This file is part of Weblate <https://weblate.org/>
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
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

from django.conf.urls import url, include
from django.conf.urls.i18n import i18n_patterns
from django.contrib import admin
from django.views.generic import TemplateView, RedirectView
from django.conf import settings
from django.contrib.sitemaps import Sitemap
import django.contrib.sitemaps.views
import django.views.static

from simple_sso.sso_client.client import Client

from weblate_web.views import (
    PaymentView, CustomerView, CompleteView, fetch_vat,
)


class PagesSitemap(Sitemap):
    '''
    Sitemap of static pages for one language.
    '''
    def __init__(self, language):
        super().__init__()
        self.language = language

    def items(self):
        return (
            ('/', 1.0, 'weekly'),
            ('/features/', 0.9, 'weekly'),
            ('/tour/', 0.9, 'monthly'),
            ('/download/', 0.5, 'daily'),
            ('/try/', 0.5, 'weekly'),
            ('/hosting/', 0.8, 'monthly'),
            ('/contribute/', 0.7, 'monthly'),
            ('/donate/', 0.7, 'weekly'),
            ('/support/', 0.7, 'monthly'),
            ('/thanks/', 0.2, 'monthly'),
            ('/terms/', 0.2, 'monthly'),
        )

    def location(self, obj):
        return '/{0}{1}'.format(self.language, obj[0])

    def priority(self, obj):
        if self.language == 'en':
            return obj[1]
        return obj[1] * 3 / 4

    def changefreq(self, obj):
        # pylint: disable=R0201
        return obj[2]


# create each section in all languages
SITEMAPS = {
    lang[0]: PagesSitemap(lang[0])
    for lang in settings.LANGUAGES
}
UUID = r'(?P<pk>[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})'


SSO_CLIENT = Client(
    settings.SSO_SERVER, settings.SSO_PUBLIC_KEY, settings.SSO_PRIVATE_KEY
)


urlpatterns = i18n_patterns(
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
        r'^hosting/free/$',
        TemplateView.as_view(template_name="hosting-free.html"),
        name='hosting-free'
    ),
    url(
        r'^hosting/ordered/$',
        TemplateView.as_view(template_name="hosting-ordered.html"),
        name='hosting-ordered'
    ),
    url(
        r'^contribute/$',
        TemplateView.as_view(template_name="contribute.html"),
        name='contribute'
    ),
    url(
        r'^donate/$',
        TemplateView.as_view(template_name="donate.html"),
        name='donate'
    ),
    url(
        r'^support/$',
        TemplateView.as_view(template_name="support.html"),
        name='support'
    ),
    url(
        r'^thanks/$',
        TemplateView.as_view(template_name="thanks.html"),
        name='thanks'
    ),
    url(
        r'^terms/$',
        TemplateView.as_view(template_name="terms.html"),
        name='terms'
    ),
    url(
        r'^payment/' + UUID + '/$',
        PaymentView.as_view(),
        name='payment'
    ),
    url(
        r'^payment/' + UUID + '/edit/$',
        CustomerView.as_view(),
        name='payment-customer'
    ),
    url(
        r'^payment/' + UUID + '/complete/$',
        CompleteView.as_view(),
        name='payment-complete'
    ),

    # Compatibility with disabled languages
    url(
        r'^[a-z][a-z]/$',
        RedirectView.as_view(url='/', permanent=False)
    ),
    url(
        r'^[a-z][a-z]_[A-Z][A-Z]/$',
        RedirectView.as_view(url='/', permanent=False)
    ),
    # Broken links
    url(
        r'^https?:/.*$',
        RedirectView.as_view(url='/', permanent=True)
    ),
    url(
        r'^index\.html$',
        RedirectView.as_view(url='/', permanent=True)
    ),
    url(
        r'^index\.([a-z][a-z])\.html$',
        RedirectView.as_view(url='/', permanent=True)
    ),
    url(
        r'^[a-z][a-z]/index\.html$',
        RedirectView.as_view(url='/', permanent=True)
    ),
    url(
        r'^[a-z][a-z]_[A-Z][A-Z]/index\.html$',
        RedirectView.as_view(url='/', permanent=True)
    ),
) + [
    url(
        r'^sitemap\.xml$',
        django.contrib.sitemaps.views.sitemap,
        {'sitemaps': SITEMAPS}
    ),
    url(
        r'^js/vat/$',
        fetch_vat
    ),
    url(r'^sso/', include(SSO_CLIENT.get_urls())),
    # Admin
    url(r'^admin/', admin.site.urls),

    # Media files on devel server
    url(
        r'^media/(?P<path>.*)$',
        django.views.static.serve,
        {'document_root': settings.MEDIA_ROOT}
    ),
]
