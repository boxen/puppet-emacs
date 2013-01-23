require 'spec_helper'

describe 'emacs' do
  let(:version) { '24.1-boxen1' }
  let(:facts) { { :boxen_home => '/opt/boxen' } }

  it do
    should include_class('homebrew')

    should include_homebrew__formula('emacs')

    should contain_package('boxen/brews/emacs').with_ensure(version)

    should contain_file('/Applications/Emacs.app').with({
      :ensure  => 'link',
      :target  => "/opt/boxen/homebrew/Cellar/emacs/#{version}/Emacs.app",
      :require => 'Package[boxen/brews/emacs]',
    })
  end
end
