[![Build Status](https://travis-ci.org/muriloventuroso/easyssh.svg?branch=master)](https://travis-ci.org/muriloventuroso/easyssh)

<h1 align="center">EasySSH</h1>

## The SSH connection manager to make your life easier.

A complete, efficient and easy-to-use manager. Create and edit connections, groups, customize the terminal, with multiple instances of the same connection.

<p align="center">
  <a href="https://appcenter.elementary.io/com.github.muriloventuroso.easyssh"><img src="https://appcenter.elementary.io/badge.svg" alt="Get it on AppCenter" /></a>
</p>

### Donate
<a href="https://www.paypal.me/muriloventuroso">PayPal</a> | <a href="https://www.patreon.com/muriloventuroso">Patreon</a>



![Screenshot](data/screenshot.png)


[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.muriloventuroso.easyssh)


## Developing and Building

If you want to hack on and build Palette yourself, you'll need the following dependencies:

* libgee-0.8-dev
* libgtk-3-dev
* libgranite-dev
* libvte-2.91-dev
* libjson-glib-dev
* meson
* valac

Run `meson build` to configure the build environment and run `ninja test` to build and run automated tests

    meson build --prefix=/usr
    cd build
    ninja test

To install, use `ninja install`, then execute with `com.github.muriloventuroso.easyssh`

    sudo ninja install
    com.github.muriloventuroso.easyssh


-----

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.muriloventuroso.easyssh)

