# frozen_string_literal: true

require 'license_finder'
require 'license_conflicts/conflicts_map'
require 'license_conflicts/project_metadata'

module LicenseConflicts
  class Finder
    attr_reader :config, :main_license

    def initialize
      @config ||= LicenseFinder::Configuration.with_optional_saved_config(license_finder_config)
    end

    def find_conflicts
      @main_license = project_license

      raise "license_not_found" if main_license.nil?
      raise "examinated_package_license_not_mapped_#{main_license}" unless CONFLICTS_MAP.key?(main_license)

      check_conflicts
    end

    def dependencies_count
      unapproved.count { |d| d.name != project_name }
    end

    def project_license
      examinated_package = unapproved.find { |d| d.name == project_name }
      examinated_package&.licenses&.first&.name || project_metadata.license
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
      @finder ||= LicenseFinder::LicenseAggregator.new(config, nil)
    end

    def unapproved
      @unapproved ||= finder.unapproved
    end

    def check_conflicts
      unapproved.filter { |dependency| has_conflict?(dependency.licenses.first.name) }
    end

    def has_conflict?(dependency_license)
      CONFLICTS_MAP[main_license].include?(dependency_license)
    end
  end
end
