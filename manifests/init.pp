# Public: Install Emacs.app from homebrew into /Applications.
#
# Examples
#
#   include emacs
class emacs {
  $version = '24.1-boxen1'

  homebrew::formula { 'emacs':
    before => Package['boxen/brews/emacs'] ;
  }

  package { 'boxen/brews/emacs':
    ensure => $version
  }

  file { '/Applications/Emacs.app':
    ensure  => link,
    target  => "${homebrew::config::installdir}/Cellar/emacs/${version}/Emacs.app",
    require => Package['boxen/brews/emacs']
  }
}
