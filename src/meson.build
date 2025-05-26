dependencies = [
    posix,
    dependency('gtk+-3.0'),
    meson.get_compiler('c').find_library('m', required: true)
]

sources = files('main.vala')
install_data('../data/icon.svg', install_dir : get_option('datadir') / 'ideapadvantage')
install_data('../data/ideapadvantage.desktop', install_dir : '/usr/share/applications')

executable('ideapadvantage', sources, dependencies:dependencies, install:true)
