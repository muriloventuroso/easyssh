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
from django.utils import timezone
from django.utils.translation import ugettext_lazy, ugettext

from wlhosted.payments.models import (
    Payment, RECURRENCE_CHOICES, get_period_delta,
)

PAYMENTS_ORIGIN = 'https://weblate.org/donate/process/'


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

    def get_display_name(self):
        return ugettext(self.name)


class Donation(models.Model):
    user = models.ForeignKey(User, on_delete=models.deletion.CASCADE)
    payment = models.UUIDField()
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

    def get_payment(self):
        return Payment.objects.get(pk=self.payment)

    def list_payments(self):
        initial = Payment.objects.filter(pk=self.payment)
        return initial | initial[0].payment_set.all()

    def get_absolute_url(self):
        return reverse('donate-edit', kwargs={'pk': self.pk})


def process_payment(payment):
    if payment.repeat:
        # Update existing
        donation = Donation.objects.get(payment=payment.repeat.pk)
        donation.expires += get_period_delta(payment.repeat.recurring)
        donation.save()
    else:
        user = User.objects.get(pk=payment.customer.user_id)
        reward = None
        if 'reward' in payment.extra:
            reward = Reward.objects.get(pk=payment.extra['reward'])
        # Calculate expiry
        expires = timezone.now()
        if payment.recurring:
            expires += get_period_delta(payment.recurring)
        # Create new
        donation = Donation.objects.create(
            user=user,
            payment=payment.pk,
            reward=reward,
            expires=expires,
            active=True,
        )
    payment.state = Payment.PROCESSED
    payment.save()
    return donation
