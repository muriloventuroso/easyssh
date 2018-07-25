project('com.github.muriloventuroso.easyssh', 'vala', 'c')

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="' + meson.project_name() + '"', language:'c')

# Add locale support
conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('PREFIX', get_option('prefix'))
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('PACKAGE', meson.project_name())
conf.set_quoted('LOCALE_DIR', join_paths(get_option('prefix'), get_option('localedir')))
conf.set_quoted('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
conf.set_quoted('PKGDATADIR', join_paths(get_option('prefix'), get_option('datadir'), meson.project_name()))
code_resources = gnome.compile_resources(
    'code-resources', 'data/' + meson.project_name() + '.gresource.xml',
    source_dir: 'data'
)

configure_file(
  output: 'config.h',
  configuration: conf
)
config_h_dir = include_directories('src')

# Arguments C - no gcc warnings
c_args = [
  '-include', 'config.h',
  '-w', '-DGETTEXT_PACKAGE="' + meson.project_name() + '"'
]

subdir('data')
subdir('po')
executable(
    meson.project_name(),
    code_resources,
    'src/Application.vala',
    'src/Host.vala',
    'src/MainWindow.vala',
    'src/Services/Settings.vala',
    'src/Views/SourceListView.vala',
    'src/Widgets/TerminalBox.vala',
    'src/Widgets/Welcome.vala',
    'src/Widgets/HeaderBar.vala',
    'src/Widgets/ConnectionEditor.vala',
    'src/Widgets/Connection.vala',
    'src/Widgets/ErrorRevealer.vala',
    'src/Widgets/Preferences.vala',
    'src/Widgets/TerminalWidget.vala',
    dependencies: [
        dependency('gee-0.8'),
        dependency('glib-2.0'),
        dependency('gtk+-3.0'),
        dependency('granite'),
        dependency('json-glib-1.0'),
        dependency('vte-2.91', version: '>0.52'),
        dependency('gee-0.8'),
        dependency('unity'),
        meson.get_compiler('c').find_library('m', required : false)
    ],
    install: true
)

meson.add_install_script('meson/post_install.py')
