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

from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.core.exceptions import SuspiciousOperation
from django.db import transaction
from django.http import JsonResponse, Http404
from django.shortcuts import redirect
from django.urls import reverse
from django.utils.decorators import method_decorator
from django.utils.translation import ugettext as _
from django.views.generic.edit import FormView, UpdateView
from django.views.decorators.http import require_POST

from django.views.generic.detail import SingleObjectMixin

from wlhosted.payments.backends import get_backend, list_backends

from wlhosted.payments.models import Payment, Customer
from wlhosted.payments.forms import CustomerForm
from wlhosted.payments.validators import cache_vies_data

from weblate_web.forms import MethodForm, DonateForm, EditLinkForm
from weblate_web.models import (
    Donation, Reward, PAYMENTS_ORIGIN, process_payment,
)


@require_POST
def fetch_vat(request):
    if 'payment' not in request.POST or 'vat' not in request.POST:
        raise SuspiciousOperation('Missing needed parameters')
    payment = Payment.objects.filter(
        pk=request.POST['payment'], state=Payment.NEW
    )
    if not payment.exists():
        raise SuspiciousOperation('Already processed payment')
    vat = cache_vies_data(request.POST['vat'])
    return JsonResponse(data=getattr(vat, 'vies_data', {'valid': False}))


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

    def get_context_data(self, **kwargs):
        kwargs = super().get_context_data(**kwargs)
        kwargs['can_pay'] = self.can_pay
        kwargs['backends'] = [x(self.object) for x in list_backends()]
        return kwargs

    def get(self, request, *args, **kwargs):
        if self.object.customer.is_eu_enduser:
            messages.error(
                request,
                'Payments for EU endusers are currently not possible. '
                'Please contact us at billing@weblate.org.'
            )
        return super().get(request, *args, **kwargs)

    def dispatch(self, request, *args, **kwargs):
        with transaction.atomic(using='payments_db'):
            self.object = self.get_object()
            customer = self.object.customer
            self.can_pay = not customer.is_empty and not customer.is_eu_enduser
            # Redirect already processed payments to origin in case
            # the web redirect was aborted
            if self.object.state != Payment.NEW:
                return self.redirect_origin()
            if self.check_customer and customer.is_empty:
                messages.info(
                    self.request,
                    _(
                        'Please provide your billing information to '
                        'complete the payment.'
                    )
                )
                return redirect('payment-customer', pk=self.object.pk)
            return super().dispatch(request, *args, **kwargs)

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
        kwargs = super().get_form_kwargs()
        kwargs['instance'] = self.object.customer
        return kwargs


class CompleteView(PaymentView):
    def dispatch(self, request, *args, **kwargs):
        with transaction.atomic(using='payments_db'):
            self.object = self.get_object()
            if self.object.state == Payment.NEW:
                return redirect('payment', pk=self.object.pk)
            if self.object.state != Payment.PENDING:
                return self.redirect_origin()

            backend = get_backend(self.object.backend)(self.object)
            backend.complete(self.request)
            return self.redirect_origin()


@method_decorator(login_required, name='dispatch')
class DonateView(FormView):
    form_class = DonateForm
    template_name = 'donate/form.html'
    show_form = True

    def get_form_kwargs(self):
        result = super().get_form_kwargs()
        if 'recurrence' in self.request.GET:
            result['initial'] = {'recurrence': self.request.GET['recurrence']}
        return result

    @staticmethod
    def get_rewards():
        return Reward.objects.filter(
            third_party=False, active=True
        ).order_by('amount')

    def get_context_data(self, **kwargs):
        kwargs = super().get_context_data(**kwargs)
        kwargs['rewards'] = self.get_rewards()
        kwargs['show_form'] = self.show_form
        return kwargs

    def redirect_payment(self, **kwargs):
        kwargs['customer'] = Customer.objects.get_or_create(
            origin=PAYMENTS_ORIGIN,
            user_id=self.request.user.id,
            defaults={
                'email': self.request.user.email,
            }
        )[0]
        payment = Payment.objects.create(**kwargs)
        return redirect(payment.get_payment_url())

    def handle_reward(self, reward):
        return self.redirect_payment(
            amount=reward.amount,
            amount_fixed=True,
            description='Weblate donation: {}'.format(reward.name),
            recurring=reward.recurring,
            extra={
                'reward': str(reward.pk),
            }
        )

    def form_valid(self, form):
        return self.redirect_payment(
            amount=form.clened_data['amount'],
            amount_fixed=True,
            description='Weblate donation',
            recurring=form.cleaned_data['recurring'],
        )

    def post(self, request, *args, **kwargs):
        if 'reward' in request.POST:
            try:
                reward = self.get_rewards().get(pk=request.POST['reward'])
                return self.handle_reward(reward)
            except Reward.DoesNotExist:
                pass
        return super().post(request, *args, **kwargs)


class DonateRewardView(DonateView):
    show_form = False

    def get_rewards(self):
        rewards = Reward.objects.filter(pk=self.kwargs['pk'], active=True)
        if not rewards:
            raise Http404('Reward not found')
        return rewards


@login_required
def process_donation(request):
    try:
        payment = Payment.objects.get(
            pk=request.GET['payment'],
            customer__origin=PAYMENTS_ORIGIN,
            customer__user_id=request.user.id
        )
    except (KeyError, Payment.DoesNotExist):
        return redirect(reverse('donate-new'))

    # Create donation
    if payment.state in (Payment.NEW, Payment.PENDING):
        messages.error(
            request,
            _('Payment not yet processed, please retry.')
        )
    elif payment.state == Payment.REJECTED:
        messages.error(
            request,
            _('The payment was rejected: {}').format(
                payment.details.get('reject_reason', _('Unknown reason'))
            )
        )
    elif payment.state == Payment.ACCEPTED:
        messages.success(request, _('Thank you for your donation.'))
        donation = process_payment(payment)
        if donation.reward and donation.reward.has_link:
            return redirect(donation)

    return redirect(reverse('donate'))


@method_decorator(login_required, name='dispatch')
class EditLinkView(UpdateView):
    form_class = EditLinkForm
    template_name = 'donate/edit.html'
    success_url = '/donate/'

    def get_queryset(self):
        return Donation.objects.filter(
            user=self.request.user,
            reward__has_link=True
        )
