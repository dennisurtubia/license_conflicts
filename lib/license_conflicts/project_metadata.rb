# frozen_string_literal: true

require "json"
require "pathname"

module LicenseConflicts
  class ProjectMetadata
    def name
      @name ||= read_name
    end

    def license
      @license ||= read_license
    end

    private

    def read_name
      package_json_data&.dig("name") ||
        bower_json_data&.dig("name") ||
        gemspec_data&.dig(:name) ||
        setup_cfg_data&.dig(:name) ||
        pyproject_toml_data&.dig(:name) ||
        go_mod_data&.dig(:name) ||
        godeps_data&.dig(:name) ||
        pom_xml_data&.dig(:name) ||
        Pathname.pwd.basename.to_s
    end

    def read_license
      package_json_data&.dig("license") ||
        bower_json_data&.dig("license") ||
        gemspec_data&.dig(:license) ||
        setup_cfg_data&.dig(:license) ||
        pyproject_toml_data&.dig(:license) ||
        pom_xml_data&.dig(:license)
    end

    def package_json_data
      return unless File.exist?("./package.json")

      @package_json_data ||= JSON.parse(File.read("./package.json"))
    rescue JSON::ParserError
      nil
    end

    def bower_json_data
      return unless File.exist?("./bower.json")

      @bower_json_data ||= JSON.parse(File.read("./bower.json"))
    rescue JSON::ParserError
      nil
    end

    def gemspec_data
      gemspec_file = Dir.glob("./*.gemspec").first
      return unless gemspec_file

      @gemspec_data ||= begin
        content = File.read(gemspec_file)
        name    = content[/\.name\s*=\s*["']([^"']+)["']/, 1]
        license = content[/\.license\s*=\s*["']([^"']+)["']/, 1]
        { name: name, license: license }
      end
    end

    def setup_cfg_data
      return unless File.exist?("./setup.cfg")

      @setup_cfg_data ||= begin
        content = File.read("./setup.cfg")
        name    = content[/^name\s*=\s*(.+)/, 1]&.strip
        license = content[/^license\s*=\s*(.+)/, 1]&.strip
        { name: name, license: license }
      end
    end

    def pyproject_toml_data
      return unless File.exist?("./pyproject.toml")

      @pyproject_toml_data ||= begin
        require "tomlrb"
        data    = Tomlrb.load_file("./pyproject.toml")
        project = data["project"] || data.dig("tool", "poetry") || {}
        license = project["license"]
        license = license["text"] if license.is_a?(Hash)
        { name: project["name"], license: license }
      rescue LoadError
        nil
      end
    end

    def go_mod_data
      return unless File.exist?("./go.mod")

      @go_mod_data ||= begin
        name = File.read("./go.mod")[/^module\s+(\S+)/, 1]
        { name: name }
      end
    end

    def godeps_data
      return unless File.exist?("./Godeps/Godeps.json")

      @godeps_data ||= begin
        data = JSON.parse(File.read("./Godeps/Godeps.json"))
        { name: data["ImportPath"] }
      rescue JSON::ParserError
        nil
      end
    end

    def pom_xml_data
      return unless File.exist?("./pom.xml")

      @pom_xml_data ||= begin
        require "rexml/document"
        doc     = REXML::Document.new(File.read("./pom.xml"))
        name    = REXML::XPath.first(doc, "//project/name")&.text ||
                  REXML::XPath.first(doc, "//project/artifactId")&.text
        license = REXML::XPath.first(doc, "//project/licenses/license/name")&.text
        { name: name, license: license }
      rescue REXML::ParseException
        nil
      end
    end
  end
end
