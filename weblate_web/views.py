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
from django.urls import reverse
from django.utils.translation import ugettext as _
from django.views.generic.edit import FormView
from django.views.generic.detail import SingleObjectMixin

from wlhosted.payments.backends import get_backend, list_backends

from wlhosted.payments.models import Payment

from weblate_web.forms import MethodForm, CustomerForm


class PaymentView(FormView, SingleObjectMixin):
    model = Payment
    form_class = MethodForm
    template_name = 'payment/payment.html'
    check_customer = True

    def redirect_origin(self):
        return redirect(
            '{}?payment={}'.format(
                self.object.customer.origin,
                self.object.pk,
            )
        )
        kwargs['can_pay'] = self.object.customer.is_empty

    def get_context_data(self, **kwargs):
        kwargs = super(PaymentView, self).get_context_data(**kwargs)
        kwargs['can_pay'] = self.can_pay
        kwargs['backends'] = [x(self.object) for x in list_backends()]
        return kwargs

    def get(self, request, *args, **kwargs):
        if self.object.customer.is_eu_enduser:
            messages.error(
                request,
                'Payments for EU endusers are currently not possible. '
                'Please contact us at support@weblate.org.'
            )
        return super(PaymentView, self).get(request, *args, **kwargs)

    def dispatch(self, request, *args, **kwargs):
        self.object = self.get_object()
        self.can_pay = (
            not self.object.customer.is_empty and
            not self.object.customer.is_eu_enduser
        )
        # Redirect already processed payments to origin in case
        # the web redirect was aborted
        if self.object.state != Payment.NEW:
            return self.redirect_origin()
        if self.check_customer and self.object.customer.is_empty:
            messages.info(
                self.request,
                _(
                    'Please provide your billing information to '
                    'complete the payment.'
                )
            )
            return redirect('payment-customer', pk=self.object.pk)
        return super(PaymentView, self).dispatch(request, *args, **kwargs)

    def form_valid(self, form):
        if not self.can_pay:
            return redirect('payment', pk=self.object.pk)
        # Actualy call the payment backend
        method = form.cleaned_data['method']
        backend = get_backend(method)(self.object)
        result = backend.initiate(
            self.request,
            self.request.build_absolute_uri(
                reverse('payment', kwargs={'pk': self.object.pk})
            ),
            self.request.build_absolute_uri(
                reverse('payment-complete', kwargs={'pk': self.object.pk})
            ),
        )
        if result is not None:
            return result
        backend.complete(self.request)
        return self.redirect_origin()


class CustomerView(PaymentView):
    form_class = CustomerForm
    template_name = 'payment/customer.html'
    check_customer = False

    def form_valid(self, form):
        form.save()
        return redirect('payment', pk=self.object.pk)

    def get_form_kwargs(self):
        """Return the keyword arguments for instantiating the form."""
        kwargs = super(CustomerView, self).get_form_kwargs()
        kwargs['instance'] = self.object.customer
        return kwargs


class CompleteView(PaymentView):
    def dispatch(self, request, *args, **kwargs):
        self.object = self.get_object()
        if self.object.state == Payment.NEW:
            return redirect('payment', pk=self.object.pk)
        elif self.object.state != Payment.PENDING:
            return self.redirect_origin()

        backend = get_backend(self.object.details['backend'])(self.object)
        backend.complete(self.request)
        return self.redirect_origin()
