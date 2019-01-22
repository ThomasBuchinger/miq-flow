# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new

desc 'Run everything test related'
task travis: %i[spec rubocop]

RSpec::Core::RakeTask.new(:spec)
RSpec::Core::RakeTask.new(:"spec:integration") do |config|
end

task default: :spec
