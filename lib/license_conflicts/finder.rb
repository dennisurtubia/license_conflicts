# frozen_string_literal: true

require 'license_finder'
require 'license_conflicts/conflicts_map'
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
      unapproved.count { |d| d.name != project_name }
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

    def check_conflicts
      unapproved.filter { |dependency| has_conflict?(dependency.licenses.first&.name) }
    end

    def has_conflict?(dependency_license)
      CONFLICTS_MAP[main_license].include?(LicenseNormalizer.normalize(dependency_license))
    end
  end
end
