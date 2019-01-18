# frozen_string_literal: true

require 'rspec'
require 'webmock/rspec'

$LOAD_PATH.unshift(File.join(__dir__, '..', 'lib'))
RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 10_000
