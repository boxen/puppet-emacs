class emacs {
  $version = '24.1-github1'

  package { 'github/brews/emacs':
    ensure => $version
  }

  file { "/Applications/Emacs.app":
    ensure  => link,
    target  => "${homebrew::dir}/Cellar/${version}/Emacs.app",
    require => Package['github/brews/emacs']
  }
}
