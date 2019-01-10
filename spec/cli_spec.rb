# frozen_string_literal: true

require 'spec_helper.rb'
require 'bootstrap.rb'
require 'cli/cli.rb'

RSpec.describe GitFlow::Cli::MainCli do
  before(:all) do
    GitFlow::Settings.update_log_level(:unknown)
  end

  context 'General handling' do
    it 'does display help' do
      expect{ subject.invoke(:help) }.to output(/Commands:/).to_stdout
    end
    it 'exits 1 on missing command' do
      expect{ subject.invoke(:not_existing) }.to raise_error(/Missing Thor class/)
    end
  end

  context 'Misc Commands' do
    it 'list git' do
      expect{ subject.invoke(:list, ['git']) }.to output(%r{origin/feature-1-f1}).to_stdout
    end
    it 'list miq' do
      expect{ subject.invoke(:list, ['miq']) }.to output(/ManageIQ/).to_stdout
    end
    it 'inspect' do
      expect{ subject.invoke(:inspect, ['feature-1-f1']) }.to output(/Feature: f1 on branch feature-1-f1/).to_stdout
    end
    it 'deploy - nothing fancy' do
      expect{ subject.invoke(:deploy, ['feature-1-f1', '--provider', 'noop']) }.to_not raise_error
    end
  end

  context 'API Commands' do
    it{ is_expected().to be_truthy }
  end

  context 'Git Commands' do
    it{ is_expected().to be_truthy }
  end
end
