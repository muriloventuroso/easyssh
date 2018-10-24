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
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

from weblate_web.data import VERSION, EXTENSIONS, SCREENSHOTS


def weblate_web(request):
    if request.resolver_match:
        url_name = request.resolver_match.url_name
    else:
        url_name = 'home'

    downloads = [
        'Weblate-{0}.{1}'.format(VERSION, ext) for ext in EXTENSIONS
    ]
    return {
        'downloads': downloads,
        'screenshots': SCREENSHOTS,
        'url_name': url_name,
    }
