# -*- coding: utf-8 -*-
#
# Copyright © 2012 - 2013 Michal Čihař <michal@cihar.com>
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

from django.template import Library, Node, Variable, TemplateSyntaxError
import os
from django.utils.translation import ugettext as _, ungettext
from django.utils.safestring import mark_safe
from django.conf import settings

register = Library()


def filesizeformat(bytes):
    """
    Formats the value like a 'human-readable' file size (i.e. 13 KB, 4.1 MB,
    102 bytes, etc).
    """
    try:
        bytes = float(bytes)
    except (TypeError,ValueError,UnicodeDecodeError):
        return _(u"0 bytes")

    if bytes < 1024:
        return ungettext("%(size)d byte", "%(size)d bytes", bytes) % {'size': bytes}
    if bytes < 1024 * 1024:
        return _("%.1f KiB") % (bytes / 1024)
    if bytes < 1024 * 1024 * 1024:
        return _("%.1f MiB") % (bytes / (1024 * 1024))
    return _("%.1f GiB") % (bytes / (1024 * 1024 * 1024))


@register.simple_tag
def downloadlink(name, text = None):
    if text is None:
        if name[-8:] == '.tar.bz2':
            text = _('Sources tarball, bzip2 compressed')
        elif name[-7:] == '.tar.gz':
            text = _('Sources tarball, gzip compressed')
        elif name[-9:] == '.tar.lzma':
            text = _('Sources tarball, lzma compressed')
        elif name[-7:] == '.tar.xz':
            text = _('Sources tarball, xz compressed')
        elif name[-4:] == '.zip':
            text = _('Sources, zip compressed')
        elif name[-3:] == '.7z':
            text = _('Sources, 7zip compressed')
        else:
            text = os.path.split(name)[1]

    filesize = os.path.getsize(os.path.join(settings.FILES_PATH, name))

    size = filesizeformat(filesize)

    return mark_safe('<a href="%(base)s%(name)s">%(text)s (%(size)s)</a>' % {
        'base': settings.FILES_URL,
        'name': name,
        'text': text,
        'size': size,
    })
