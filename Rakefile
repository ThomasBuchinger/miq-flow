# frozen_string_literal: true

require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new

desc 'Run everything test related'
task travis: %i[spec rubocop]

RSpec::Core::RakeTask.new(:spec) do |config|
  config.rspec_opts = '--format doc'
end
RSpec::Core::RakeTask.new(:"spec:integration") do |config|
end

task :default do
  puts 'There are no test yet. Sorry'
end
