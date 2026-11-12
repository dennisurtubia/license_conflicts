# frozen_string_literal: true

require 'license_finder'
require 'license_conflicts/conflicts_map'
require "license_conflicts/declared_dependencies"
require 'license_conflicts/license_normalizer'
require 'license_conflicts/project_metadata'

module LicenseConflicts
  class Finder
    attr_reader :main_license

    def initialize
      @config ||= LicenseFinder::Configuration.with_optional_saved_config(license_finder_config)
    end

    def find_conflicts
      @main_license = LicenseNormalizer.normalize(project_license)

      raise "Could not detect the project license. Ensure your project metadata file declares a license." if main_license.nil?
      raise "License '#{main_license}' is not covered by the conflict matrix." unless CONFLICTS_MAP.key?(main_license)

      check_conflicts
    end

    def dependencies_count
      dependencies.count
    end

    def project_license
      examined_package = unapproved.find { |d| d.name == project_name }
      examined_package&.licenses&.first&.name || project_metadata.license
    end

    private

    def project_name
      project_metadata.name
    end

    def project_metadata
      @project_metadata ||= ProjectMetadata.new
    end

    def license_finder_config
      {
        prepare: true,
        logger: LicenseFinder::Logger::MODE_QUIET
      }
    end

    def finder
      @finder ||= LicenseFinder::LicenseAggregator.new(@config, nil)
    end

    def unapproved
      @unapproved ||= finder.unapproved
    end

    # Only the direct dependencies, the ones the project declares in its own manifests, are
    # analysed; transitive dependencies that LicenseFinder also reports are left out. When no
    # supported manifest is found, every dependency LicenseFinder reports is kept.
    def dependencies
      @dependencies ||= begin
        others = unapproved.reject { |d| d.name == project_name }
        declared = DeclaredDependencies.new
        declared.names ? one_per_name(others.select { |d| declared.include?(d.name) }) : others
      end
    end

    # A package manager may report several versions of the same name (the direct dependency and
    # transitive copies); keep the one whose version matches the copy at its install path.
    def one_per_name(packages)
      packages.group_by { |d| DeclaredDependencies.key(d.name) }.map do |_key, versions|
        next versions.first if versions.one?

        versions.find { |d| d.install_path && ProjectMetadata.new(d.install_path.to_s).version == d.version } ||
          versions.first
      end
    end

    def check_conflicts
      dependencies.filter { |dependency| has_conflict?(dependency.licenses.first&.name) }
    end

    def has_conflict?(dependency_license)
      CONFLICTS_MAP[main_license].include?(LicenseNormalizer.normalize(dependency_license))
    end
  end
end
