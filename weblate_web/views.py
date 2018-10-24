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

from django.shortcuts import redirect
from django.views.generic.edit import FormView
from django.views.generic.detail import SingleObjectMixin

from wlhosted.payments.models import Payment

from weblate_web.forms import MethodForm


class PaymentView(FormView, SingleObjectMixin):
    model = Payment
    form_class = MethodForm
    template_name = 'payment/payment.html'

    def get_queryset(self):
        return Payment.objects.filter(handled=False)

    def dispatch(self, request, *args, **kwargs):
        self.object = self.get_object()
        # Redirect already paid back to source in case
        # the transaction was aborted
        if self.object.paid:
            return redirect(self.object.origin)
        return super(PaymentView, self).dispatch(request, *args, **kwargs)
