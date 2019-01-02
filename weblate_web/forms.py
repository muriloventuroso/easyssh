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

from __future__ import unicode_literals

from django import forms
from django.utils.translation import ugettext_lazy as _

from wlhosted.payments.backends import list_backends


class MethodForm(forms.Form):
    method = forms.ChoiceField(
        choices=[],
        required=True,
    )

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['method'].choices = [
            (backend.name, backend.verbose) for backend in list_backends()
        ]


class DonateForm(forms.Form):
    recurrence = forms.ChoiceField(
        label=_('Donation recurrence'),
        choices=[
            ('onetime', _('One time donation')),
            ('monthly', _('Monthly donation')),
            ('yearly', _('Yearly donation')),
        ],
        initial='monthly',
        widget=forms.RadioSelect,
    )
    amount = forms.IntegerField(
        label=_('Amount in EUR'),
        min_value=2,
        initial=10,
    )
