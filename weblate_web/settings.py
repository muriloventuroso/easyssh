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

#
# Django settings for weblate website project.
#

import os
import sentry_sdk
from sentry_sdk.integrations.django import DjangoIntegration

DEBUG = True

ADMINS = (
    # ('Your Name', 'your_email@example.com'),
)

MANAGERS = ADMINS

DATABASES = {
    'default': {
        # Use 'postgresql_psycopg2', 'mysql', 'sqlite3' or 'oracle'.
        'ENGINE': 'django.db.backends.sqlite3',
        # Database name or path to database file if using sqlite3.
        'NAME': 'db.sqlite3',
        # Database user, not used with sqlite3.
        'USER': '',
        # Database pasword, not used with sqlite3.
        'PASSWORD': '',
        # Set to empty string for localhost. Not used with sqlite3.
        'HOST': '',
        # Set to empty string for default. Not used with sqlite3.
        'PORT': '',
    }
}

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Local time zone for this installation. Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
# although not all choices may be available on all operating systems.
# In a Windows environment this must be set to your system time zone.
TIME_ZONE = 'Europe/Prague'

# Language code for this installation. All choices can be found here:
# http://www.i18nguy.com/unicode/language-identifiers.html
LANGUAGE_CODE = 'en-us'

LANGUAGES = (
    ('ar', u'العربية'),
    ('az', u'Azərbaycan'),
    ('be', u'Беларуская'),
    ('be@latin', u'Biełaruskaja'),
    ('bg', u'Български'),
    ('br', u'Brezhoneg'),
    ('ca', u'Català'),
    ('cs', u'Čeština'),
    ('da', u'Dansk'),
    ('de', u'Deutsch'),
    ('en', u'English'),
    ('el', u'Ελληνικά'),
    ('en-gb', u'English (United Kingdom)'),
    ('es', u'Español'),
    ('fi', u'Suomi'),
    ('fr', u'Français'),
    ('gl', u'Galego'),
    ('he', u'עברית'),
    ('hu', u'Magyar'),
    ('id', u'Indonesia'),
    ('it', u'Italiano'),
    ('ja', u'日本語'),
    ('ko', u'한국어'),
    ('nb', u'Norsk bokmål'),
    ('nl', u'Nederlands'),
    ('pl', u'Polski'),
    ('pt', u'Português'),
    ('pt-br', u'Português brasileiro'),
    ('ru', u'Русский'),
    ('sk', u'Slovenčina'),
    ('sl', u'Slovenščina'),
    ('sq', u'Shqip'),
    ('sr', u'Српски'),
    ('sv', u'Svenska'),
    ('tr', u'Türkçe'),
    ('uk', u'Українська'),
    ('zh-hans', u'简体字'),
    ('zh-hant', u'正體字'),
)

SITE_ID = 1

# If you set this to False, Django will make some optimizations so as not
# to load the internationalization machinery.
USE_I18N = True

# If you set this to False, Django will not format dates, numbers and
# calendars according to the current locale.
USE_L10N = True

# If you set this to False, Django will not use timezone-aware datetimes.
USE_TZ = False

# Absolute filesystem path to the directory that will hold user-uploaded files.
# Example: "/home/media/media.lawrence.com/media/"
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# URL that handles the media served from MEDIA_ROOT. Make sure to use a
# trailing slash.
# Examples: "http://media.lawrence.com/media/", "http://example.com/media/"
MEDIA_URL = '/media/'

# Absolute path to the directory static files should be collected to.
# Don't put anything in this directory yourself; store your static files
# in apps' "static/" subdirectories and in STATICFILES_DIRS.
# Example: "/home/media/media.lawrence.com/static/"
STATIC_ROOT = ''

# URL prefix for static files.
# Example: "http://media.lawrence.com/static/"
STATIC_URL = '/static/'

# Additional locations of static files
STATICFILES_DIRS = (
    # Put strings here, like "/home/html/static" or "C:/www/django/static".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
)

# List of finder classes that know how to find static files in
# various locations.
STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
)

# Make this unique, and don't share it with anybody.
SECRET_KEY = 'qov6(*cp%)b*ot+8c%#4@4or(t@_$y5#d8k9u1^+pknz%lms0x'

# Templates settings
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.template.context_processors.i18n',
                'weblate_web.context_processors.weblate_web',
            ],
            'loaders': [
                ('django.template.loaders.cached.Loader', [
                    'django.template.loaders.filesystem.Loader',
                    'django.template.loaders.app_directories.Loader',
                ]),
            ],
        },
    },
]

# Middleware
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.locale.LocaleMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'weblate_web.middleware.SecurityMiddleware',
]

ROOT_URLCONF = 'weblate_web.urls'

INSTALLED_APPS = (
    'weblate_web',
    'django.contrib.staticfiles',
    'django.contrib.sitemaps',
    'wlhosted',
)

# Some security headers
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = 'DENY'
SECURE_CONTENT_TYPE_NOSNIFF = True

# Optionally enable HSTS
SECURE_HSTS_SECONDS = 0
SECURE_HSTS_PRELOAD = False
SECURE_HSTS_INCLUDE_SUBDOMAINS = False

# A sample logging configuration. The only tangible logging
# performed by this configuration is to send an email to
# the site admins on every HTTP 500 error when DEBUG=False.
# See http://docs.djangoproject.com/en/dev/topics/logging for
# more details on how to customize your logging configuration.
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse'
        }
    },
    'handlers': {
        'mail_admins': {
            'level': 'ERROR',
            'filters': ['require_debug_false'],
            'class': 'django.utils.log.AdminEmailHandler'
        },
    },
    'loggers': {
        'django.request': {
            'handlers': ['mail_admins'],
            'level': 'ERROR',
            'propagate': True,
        },
    }
}

FILES_PATH = os.path.join(BASE_DIR, 'files')
FILES_URL = 'https://dl.cihar.com/weblate/'
LOCALE_PATHS = (
    os.path.join(BASE_DIR, '..', 'locale'),
)

ALLOWED_HOSTS = ('weblate.org', '127.0.0.1')

SESSION_ENGINE = "django.contrib.sessions.backends.signed_cookies"

# Force sane test runner
TEST_RUNNER = 'django.test.runner.DiscoverRunner'

sentry_sdk.init(
    dsn="",
    integrations=[DjangoIntegration()]
)
