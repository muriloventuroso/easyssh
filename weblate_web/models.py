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

import uuid

from django.db import models
from django.contrib.auth.models import User
from django.urls import reverse
from django.utils.translation import ugettext_lazy

from wlhosted.payments.models import Payment, RECURRENCE_CHOICES


class Reward(models.Model):
    uuid = models.UUIDField(
        primary_key=True, default=uuid.uuid4, editable=False
    )
    recurring = models.CharField(
        choices=RECURRENCE_CHOICES,
        default='',
        blank=True,
        max_length=10,
    )
    amount = models.PositiveIntegerField()
    has_link = models.BooleanField(blank=True)
    third_party = models.BooleanField(blank=True)
    active = models.BooleanField(blank=True)
    name = models.CharField(max_length=200)

    class Meta:
        index_together = [
            ('active', 'third_party'),
            ('has_link', 'third_party'),
        ]

    def get_absolute_url(self):
        return reverse('donate-reward', kwargs={'pk': self.pk})


class Donation(models.Model):
    user = models.ForeignKey(User, on_delete=models.deletion.CASCADE)
    payment = models.ForeignKey(Payment, on_delete=models.deletion.CASCADE)
    reward = models.ForeignKey(
        Reward, on_delete=models.deletion.CASCADE, null=True, blank=True
    )
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
    active = models.BooleanField(blank=True, db_index=True)
