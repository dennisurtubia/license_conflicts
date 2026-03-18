# frozen_string_literal: true

require 'thor'
require 'license_conflicts'

module LicenseConflicts
  class CLI < Thor
    VALID_FORMATS = LicenseConflicts::Report::FORMATS.keys.freeze

    desc "check", "Check license conflicts in the current project"
    option :format, aliases: "-f", desc: "Report format: #{VALID_FORMATS.join(', ')}"
    def check
      format = options[:format]

      if format && !VALID_FORMATS.include?(format)
        $stderr.puts "Invalid format '#{format}'. Valid options: #{VALID_FORMATS.join(', ')}"
        exit 2
      end

      $stderr.print "Analyzing dependencies..."
      finder = LicenseConflicts::Finder.new
      conflitant_dependencies = finder.find_conflicts
      $stderr.puts " done."

      conflitant_licenses = conflitant_dependencies.map { |d| d.licenses.first.name }.uniq
      parsed_conflitant_licenses = conflitant_licenses.join(';')

      $stdout.print "#{finder.dependencies_count}, #{finder.project_license}, #{parsed_conflitant_licenses}, "

      LicenseConflicts::Report.new(conflitant_dependencies, format || 'text').report if format

      exit conflitant_dependencies.empty? ? 0 : 1
    rescue StandardError => exception
      $stdout.print "#{finder.dependencies_count rescue 0}, #{finder.project_license rescue nil}, , "
      $stderr.puts exception.message
      exit 2
    end

    desc "version", "Show version"
    def version
      puts LicenseConflicts::VERSION
    end

    default_command :check
  end
end
