# frozen_string_literal: true

require 'license_finder'
require 'license_conflicts/conflicts_map'

module LicenseConflicts
  class Finder
    attr_reader :config, :main_license, :unapproved, :finder, :project_name

    def initialize(project_name)
      @project_name = project_name
      @config ||= LicenseFinder::Configuration.with_optional_saved_config(license_finder_config)
    end
  
    def find_conflicts
      examinated_package = unapproved.find { |d| d.name == project_name }
      @main_license = examinated_package.licenses.first.name
  
      check_conflicts
    end
  
    private
  
    def license_finder_config
      { prepare: true }
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
