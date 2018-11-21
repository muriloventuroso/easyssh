# -*- coding: utf-8 -*-
#
# Copyright © 2012 - 2018 Michal Čihař <michal@cihar.com>
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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

from __future__ import unicode_literals

from django.conf import settings


CSP_TEMPLATE = (
    "default-src 'self'; style-src {0}; img-src {1}; script-src {2}; "
    "connect-src 'none'; object-src 'none'; "
    "font-src maxcdn.bootstrapcdn.com; "
    "child-src 'none'; frame-ancestors 'none'; "
    "report-uri https://sentry.io/api/1305560/security/?sentry_key=795461fdeabc4ff6a3b6a6dedc495b5f"
)


# pylint: disable=old-style-class
class SecurityMiddleware:
    """Middleware that sets various security related headers.

    - Disables CSRF when payment secret is provided
    - Content-Security-Policy
    - X-XSS-Protection
    """
    def __init__(self, get_response=None):
        self.get_response = get_response

    def __call__(self, request):
        # Skip CSRF validation for requests with valid secret
        # This is used to process automatic payments
        if request.POST.get('secret') == settings.PAYMENT_SECRET:
            setattr(request, '_dont_enforce_csrf_checks', True)

        response = self.get_response(request)
        # No CSP for debug mode (to allow djdt or error pages)
        if settings.DEBUG:
            return response

        style = ["'self'", "'unsafe-inline'"]
        script = ["'self'"]
        image = ["'self'"]

        # Sentry/Raven
        script.append('cdn.ravenjs.com')

        # Piwik
        script.append('stats.cihar.com')
        script.append("'unsafe-inline'")
        image.append('stats.cihar.com')

        # The Pay
        image.append('www.thepay.cz')

        response['Content-Security-Policy'] = CSP_TEMPLATE.format(
            ' '.join(style),
            ' '.join(image),
            ' '.join(script),
        )
        response['X-XSS-Protection'] = '1; mode=block'
        return response
