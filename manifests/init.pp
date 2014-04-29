# Public: Install Emacs.app from homebrew into /Applications.
#
# Examples
#
#   include emacs

class emacs(
  $install_options = [
    '--cocoa',
  ],
) {
  require homebrew

  $version = '24.3-boxen4'

  homebrew::formula { 'emacs':
    before => Package['boxen/brews/emacs'] ;
  }

  package { 'boxen/brews/emacs':
    ensure          => $version,
    install_options => $install_options,
  }

  $target = "${homebrew::config::installdir}/Cellar/emacs/${version}/Emacs.app"

  file { '/Applications/Emacs.app':
    ensure  => link,
    target  => $target,
    require => Package['boxen/brews/emacs']
  }
}
