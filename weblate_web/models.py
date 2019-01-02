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

from django.db import models
from django.contrib.auth.models import User
from django.utils.functional import cached_property
from django.utils.translation import ugettext_lazy

from wlhosted.payments.models import Payment


class Donation(models.Model):
    user = models.ForeignKey(User, on_delete=models.deletion.CASCADE)
    payment = models.ForeignKey(Payment, on_delete=models.deletion.CASCADE)
    amount = models.PositiveIntegerField()
    link_text = models.CharField(
        verbose_name=ugettext_lazy('Link text'),
        max_length=200, blank=True
    )
    link_url = models.URLField(
        verbose_name=ugettext_lazy('Link URL'),
        blank=True
    )
    created = models.DateTimeField(auto_now_add=True)
    expires = models.DateTimeField()
    third_party = models.BooleanField(blank=True)

    @cached_property
    def has_thanks_link(self):
        amount = self.amount

        # For yearly payment the threshold is 10 * monthly
        if self.payment.recurring == 'y':
            amount = amount / 10

        return amount >= 100
