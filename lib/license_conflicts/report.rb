# frozen_string_literal: true

require 'license_finder'

module LicenseConflicts
  class Report
    attr_reader :format, :dependencies

    FORMATS = {
      'text' => LicenseFinder::TextReport,
      'html' => LicenseFinder::HtmlReport,
      'markdown' => LicenseFinder::MarkdownReport,
      'csv' => LicenseFinder::CsvReport,
      'xml' => LicenseFinder::XmlReport,
      'json' => LicenseFinder::JsonReport,
      'junit' => LicenseFinder::JunitReport
    }.freeze

    def initialize(dependencies, format)
      @dependencies = dependencies
      @format = format
    end

    def report
      report = FORMATS[format] || FORMATS['text']
      puts report.of(dependencies, {})
    end
  end
end
