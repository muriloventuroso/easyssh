project('com.github.muriloventuroso.easyssh', 'vala', 'c', version: '1.7.8')

gnome = import('gnome')
i18n = import('i18n')
with_gpg = get_option('with-gpg')
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language:'c')

if get_option('ubuntu-bionic-patched-vte')
    add_project_arguments(['--define', 'UBUNTU_BIONIC_PATCHED_VTE'], language : 'vala')
endif

if get_option('patched-vte')
    add_project_arguments(['--define', 'PATCHED_VTE'], language : 'vala')
endif

asresources = gnome.compile_resources(
    'as-resources', 'data/' + meson.project_name() + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'src' / 'Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

dependencies = [
    dependency('gee-0.8'),
    dependency('glib-2.0'),
    dependency('gtk+-3.0'),
    dependency('granite', version: '>=6.0.0'),
    dependency('json-glib-1.0'),
    dependency('vte-2.91', version: '>0.52'),
    dependency('gee-0.8'),
    meson.get_compiler('c').find_library('m', required : false)
]

if with_gpg
    gpg = find_program('gpg', 'gpg2', required: true)
    add_project_arguments(['--define', 'WITH_GPG'], language : 'vala')
endif

executable(
    meson.project_name(),
    asresources,
    config_file,
    'src/Application.vala',
    'src/Host.vala',
    'src/Account.vala',
    'src/Bookmark.vala',
    'src/MainWindow.vala',
    'src/Views/SourceListView.vala',
    'src/Widgets/TerminalBox.vala',
    'src/Widgets/Welcome.vala',
    'src/Widgets/WelcomeAccounts.vala',
    'src/Widgets/HeaderBar.vala',
    'src/Widgets/ConnectionEditor.vala',
    'src/Widgets/AccountEditor.vala',
    'src/Widgets/Connection.vala',
    'src/Widgets/ErrorRevealer.vala',
    'src/Widgets/Preferences.vala',
    'src/Widgets/TerminalWidget.vala',
    'src/Widgets/SearchToolbar.vala',
    'src/Widgets/BookmarksPopover.vala',
    'src/Widgets/Tab.vala',
    dependencies: dependencies,
    install: true
)

meson.add_install_script('meson/post_install.py')

subdir('data')
subdir('po')