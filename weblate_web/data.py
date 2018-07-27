# -*- coding: utf-8 -*-
#
# Copyright © 2012 - 2015 Michal Čihař <michal@cihar.com>
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

from django.utils.translation import ugettext_lazy as _

# Version offered for download
VERSION = '3.1.1'

# Extensions offered for donwload
EXTENSIONS = ('tar.xz', 'tar.bz2', 'tar.gz')

# List of screenshots
SCREENSHOTS = (
    (
        'own-translations.png',
        _('Overview of own translations at main page.'),
        _('Own translations'),
    ),
    (
        'translation-context.png',
        _(
            'Translator can always see important context information like '
            'comments or corresponding source code.'
        ),
        _('Translation context'),
    ),
    (
        'project-overview.png',
        _(
            'Project page gives you detailed information about project '
            'translation status.'
        ),
        _('Project overview'),
    ),
    (
        'glossary.png',
        _(
            'Translators can define their own glossary to stay consistent '
            'in frequently used terminology.'
        ),
        _('Glossary'),
    ),
    (
        'checks.png',
        _(
            'Customizable quality checks will help you in improving quality '
            'of translations.'
        ),
        _('Quality checks'),
    ),
    (
        'promote.png',
        _(
            'Weblate provides you various ways to promote your '
            'translation project.'
        ),
        _('Promotion'),
    ),
    (
        'addons.png',
        _(
            'Translation workflow can be customized by using addons.'
        ),
        _('Addons'),
    ),
    (
        'automatic-translation.png',
        _(
            'Automatic translation can be used to bootstrap your translations '
            'using machine translation services or translation memory.'
        ),
        _('Automatic translation'),
    ),
    (
        'export-import.png',
        _(
            'Translations can be exported and imported in many widely used '
            'file formats.'
        ),
        _('Export and import')
    ),
    (
        'manage-users.png',
        _('You can define access levels for every user.'),
        _('User management'),
    ),
)
