project('com.github.cassidyjames.palette', 'vala', 'c')

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="' + meson.project_name() + '"', language:'c')

asresources = gnome.compile_resources(
    'as-resources', 'data/' + meson.project_name() + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

executable(
    meson.project_name(),
    asresources,
    'src/Application.vala',
    'src/Colors.vala',
    'src/MainWindow.vala',
    'src/Widgets/ColorButton.vala',
    'src/Widgets/ColorVariant.vala',
    dependencies: [
        dependency('gee-0.8'),
        dependency('glib-2.0'),
        dependency('gtk+-3.0')
    ],
    install: true
)
subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
