# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'miq_flow/version'

Gem::Specification.new do |spec|
  spec.name          = 'miq_flow'
  spec.version       = MiqFlow::VERSION
  spec.authors       = ['Thomas Buchinger']
  spec.email         = ['thomas.buchinger@outlook.com']

  spec.summary       = 'This command line utility implements a git-based branching workflow on top of the default ManageIQ Automate Import scripts.'
  # spec.description   = %q{}
  spec.homepage      = 'https://github.com/ThomasBuchinger/automate-gitflow'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/ThomasBuchinger/automate-gitflow'
    spec.metadata['changelog_uri'] = 'https://github.com/ThomasBuchinger/automate-gitflow/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject{ |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}){ |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rest-client', '~> 2.0'
  spec.add_dependency 'rugged'
  spec.add_dependency 'thor'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'webmock', '~> 3.0'
end
