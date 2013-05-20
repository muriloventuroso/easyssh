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

#
# Django settings for run inside Jenkins
#

from weblate_web.settings import *
import os

INSTALLED_APPS += ('django_jenkins', )

JENKINS_TASKS = (
    'django_jenkins.tasks.run_pylint',
    'django_jenkins.tasks.run_pyflakes',
    'django_jenkins.tasks.run_sloccount',
    'django_jenkins.tasks.run_pep8',
    'django_jenkins.tasks.run_csslint',
    'django_jenkins.tasks.run_jshint',
)

CSSLINT_CHECKED_FILES = (
    os.path.join(WEB_ROOT, 'media/style.css'),
)

JSHINT_CHECKED_FILES = (
    os.path.join(WEB_ROOT, 'media/code.js'),
)

PROJECT_APPS = (
    'weblate_web',
)

PYLINT_RCFILE = os.path.join(WEB_ROOT, '..', 'pylint.rc')
