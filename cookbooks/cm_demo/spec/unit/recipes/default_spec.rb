#
# Cookbook:: cm_demo
# Spec:: default
#
# Copyright:: 2018, Nick Rycar, All Rights Reserved.

require 'spec_helper'

describe 'cm_demo::default' do
  context 'When all attributes are default, on Ubuntu 14.04' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end

end
