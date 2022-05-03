# frozen_string_literal: true

require_relative "lib/license_conflicts/version"

Gem::Specification.new do |spec|
  spec.name = "license_conflicts"
  spec.version = LicenseConflicts::VERSION
  spec.authors = ['Dennis Urtubia']
  spec.email = ['dennis.urtubia@gmail.com']

  spec.summary = 'Dependency license conflict checker'
  spec.homepage = 'https://github.com/dennisurtubia/license_conflicts'
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.executables = ['license_conflicts']
  spec.require_paths = ["lib"]

  spec.add_dependency 'license_finder', '~> 7.0.1'

  spec.add_development_dependency 'pry-nav', '~> 1.0.0'
end
