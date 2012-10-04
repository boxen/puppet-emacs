# Public: Install Emacs.app from homebrew into /Applications.
#
# Examples
#
#   include emacs
class emacs {
  require homebrew

  $version = '24.1-boxen1'

  package { 'boxen/brews/emacs':
    ensure => $version
  }

  file { '/Applications/Emacs.app':
    ensure  => link,
    target  => "${homebrew::dir}/Cellar/${version}/Emacs.app",
    require => Package['boxen/brews/emacs']
  }
}
