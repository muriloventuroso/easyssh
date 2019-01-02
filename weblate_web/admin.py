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

from django.contrib import admin
from django.utils.translation import ugettext_lazy as _

from weblate_web.models import Reward, Donation


class RewardAdmin(admin.ModelAdmin):
    list_display = ('name', 'amount', 'recurring')
    list_filter = ('has_link', 'active', 'third_party')
    search_fields = ('name',)


class DonationAdmin(admin.ModelAdmin):
    list_display = ('user', 'reward', 'created', 'expires')


admin.site.register(Reward, RewardAdmin)
admin.site.register(Donation, DonationAdmin)
