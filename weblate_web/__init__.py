# -*- coding: utf-8 -*-
#
# Copyright © 2012 - 2015 Michal Čihař <michal@cihar.com>
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

import django.utils.translation.trans_real as django_trans
from copy import _EmptyClass
import re

# Monkey patch locales, workaround for
# https://code.djangoproject.com/ticket/24063
django_trans.language_code_re = re.compile(
    r'^[a-z]{1,8}(?:-[a-z0-9]{1,8})*(?:@[a-z0-9]{1,20})?$', re.IGNORECASE
)
django_trans.language_code_prefix_re = re.compile(
    r'^/([\w@-]+)(/|$)'
)


class DjangoTranslation(django_trans.DjangoTranslation):
    """
    Unshared _info and _catalog to avoid Django messing up
    locale variants.

    This will not be needed in Django 1.8.
    """
    def __copy__(self):
        """
        Simplified version of copy._copy_inst extended for copying
        _info and _catalog.
        """
        result = _EmptyClass()
        result.__class__ = self.__class__
        state = self.__dict__
        result.__dict__.update(state)
        result._info = self._info.copy()
        result._catalog = self._catalog.copy()
        return result


django_trans.DjangoTranslation = DjangoTranslation
