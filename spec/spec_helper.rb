# frozen_string_literal: true

require 'bundler/setup'
require 'rspec'
require 'webmock/rspec'
require 'miq_flow'

$LOAD_PATH.unshift(File.join(__dir__, '..', 'lib'))
RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 10_000

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
