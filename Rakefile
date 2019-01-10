# frozen_string_literal: true

require 'rubocop/rake_task'

RuboCop::RakeTask.new

desc 'Run everything test related'
task travis: %i[rubocop spec]

# RSpec::Core::RakeTask.new(:spec) do |config|
#   config.rspec_opts = '--format doc'
# end
# RSpec::Core::RakeTask.new(:"spec:integration") do |config|
# end

task :default do
  puts 'There are not test yet. Sorry'
end
