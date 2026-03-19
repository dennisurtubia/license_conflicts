# frozen_string_literal: true

require_relative "lib/license_conflicts/version"

Gem::Specification.new do |spec|
  spec.name = "license_conflicts"
  spec.version = LicenseConflicts::VERSION
  spec.authors = ['Dennis Urtubia']
  spec.email = ['dennis.urtubia@gmail.com']

  spec.summary     = 'Detect license incompatibilities between a project and its dependencies'
  spec.description = 'license_conflicts identifies the license of an open-source project, ' \
                     'resolves all its dependencies via LicenseFinder, and reports any ' \
                     'license incompatibilities based on a built-in compatibility matrix. ' \
                     'Supports Ruby, Node.js, Python, Go, and Java projects.'
  spec.homepage = 'https://github.com/dennisurtubia/license_conflicts'
  spec.license  = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata = {
    "homepage_uri"          => spec.homepage,
    "source_code_uri"       => spec.homepage,
    "changelog_uri"         => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "bug_tracker_uri"       => "#{spec.homepage}/issues",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.executables = ['license_conflicts']
  spec.require_paths = ["lib"]

  spec.add_dependency 'license_finder', '~> 7.0.1'
  spec.add_dependency 'thor', '~> 1.5'

  spec.add_development_dependency 'pry-nav', '~> 1.0.0'
end
