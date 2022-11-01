# frozen_string_literal: true

require 'license_finder'
require 'license_conflicts/conflicts_map'

module LicenseConflicts
  class Finder
    attr_reader :config, :main_license, :unapproved, :finder, :package_json

    def initialize
      @config ||= LicenseFinder::Configuration.with_optional_saved_config(license_finder_config)
    end
  
    def find_conflicts
      @main_license = project_license

      raise Exception.new 'license_not_found' if main_license.nil?
      raise Exception.new "examinated_package_license_not_mapped_#{main_license}" unless LicenseConflicts::CONFLICTS_MAP.has_key?(main_license)

      check_conflicts
    end

    def dependencies_count
      unapproved.count - 1
    end

    def project_license
      examinated_package = unapproved.find { |d| d.name == project_name }
      license_finder_license_found = examinated_package.licenses.first.name unless examinated_package.nil?

      license_finder_license_found || package_json['license']
    end

    private

    def project_name
      package_json['name'] || Pathname.pwd.basename.to_s
    end

    def package_json
      file = File.open('./package.json', 'r')

      @package_json ||= JSON.parse(file.read)
    ensure
      file.close
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
      LicenseConflicts::CONFLICTS_MAP[main_license].include?(dependency_license)
    end
  end
end
