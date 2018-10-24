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

from django.contrib import messages
from django.shortcuts import redirect
from django.utils.translation import ugettext as _
from django.views.generic.edit import FormView
from django.views.generic.detail import SingleObjectMixin

from wlhosted.payments.models import Payment

from weblate_web.forms import MethodForm


class PaymentView(FormView, SingleObjectMixin):
    model = Payment
    form_class = MethodForm
    template_name = 'payment/payment.html'

    def redirect_origin(self):
        return redirect(
            '{}?payment={}'.format(
                self.object.customer.origin,
                self.object.pk,
            )
        )

    def dispatch(self, request, *args, **kwargs):
        self.object = self.get_object()
        # Redirect already processed payments to origin in case
        # the web redirect was aborted
        if self.object.state != Payment.NEW:
            return self.redirect_origin()
        return super(PaymentView, self).dispatch(request, *args, **kwargs)

    def form_valid(self, form):
        # Actualy call the payment backend
        method = form.cleaned_data['method']
        statemap = {
            'pay': Payment.ACCEPTED,
            'reject': Payment.REJECTED,
            'pending': Payment.PENDING,
        }
        if method in statemap:
            self.object.state = statemap[method]
            self.object.save()
            return self.redirect_origin()
        messages.error(self.request, _('Payment method is not yet supported!'))
        return redirect('payment', pk=self.object.pk)
