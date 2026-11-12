# frozen_string_literal: true

require "json"
require "pathname"

module LicenseConflicts
  # rubocop:disable Metrics/ClassLength -- one small reader per supported manifest format.
  class ProjectMetadata
    def initialize(root = ".")
      @root = root
    end

    def name
      @name ||= read_name
    end

    def license
      @license ||= read_license
    end

    # Version declared by the manifest, used to identify which of several reported versions of a
    # package is the one installed at its install path.
    def version
      @version ||= read_version
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
        Pathname(@root).expand_path.basename.to_s
    end

    def read_license
      package_json_data&.dig("license") ||
        bower_json_data&.dig("license") ||
        gemspec_data&.dig(:license) ||
        setup_cfg_data&.dig(:license) ||
        pyproject_toml_data&.dig(:license) ||
        pom_xml_data&.dig(:license)
    end

    def read_version
      [package_json_data, bower_json_data].filter_map { |data| data&.dig("version") }.first ||
        [gemspec_data, setup_cfg_data, pyproject_toml_data, pom_xml_data]
          .filter_map { |data| data&.dig(:version) }.first
    end

    def path(file)
      File.join(@root, file)
    end

    def package_json_data
      return unless File.exist?(path("package.json"))

      @package_json_data ||= JSON.parse(File.read(path("package.json")))
    rescue JSON::ParserError
      nil
    end

    def bower_json_data
      return unless File.exist?(path("bower.json"))

      @bower_json_data ||= JSON.parse(File.read(path("bower.json")))
    rescue JSON::ParserError
      nil
    end

    def gemspec_data
      gemspec_file = Dir.glob(path("*.gemspec")).first
      return unless gemspec_file

      @gemspec_data ||= begin
        content = File.read(gemspec_file)
        name    = content[/\.name\s*=\s*["']([^"']+)["']/, 1]
        license = content[/\.license\s*=\s*["']([^"']+)["']/, 1]
        version = content[/\.version\s*=\s*["']([^"']+)["']/, 1]
        { name: name, license: license, version: version }
      end
    end

    def setup_cfg_data
      return unless File.exist?(path("setup.cfg"))

      @setup_cfg_data ||= begin
        content = File.read(path("setup.cfg"))
        name    = content[/^name\s*=\s*(.+)/, 1]&.strip
        license = content[/^license\s*=\s*(.+)/, 1]&.strip
        version = content[/^version\s*=\s*(.+)/, 1]&.strip
        { name: name, license: license, version: version }
      end
    end

    def pyproject_toml_data
      return unless File.exist?(path("pyproject.toml"))

      @pyproject_toml_data ||= begin
        require "tomlrb"
        data    = Tomlrb.load_file(path("pyproject.toml"))
        project = data["project"] || data.dig("tool", "poetry") || {}
        license = project["license"]
        license = license["text"] if license.is_a?(Hash)
        { name: project["name"], license: license, version: project["version"] }
      rescue LoadError
        nil
      end
    end

    def go_mod_data
      return unless File.exist?(path("go.mod"))

      @go_mod_data ||= begin
        name = File.read(path("go.mod"))[/^module\s+(\S+)/, 1]
        { name: name }
      end
    end

    def godeps_data
      return unless File.exist?(path("Godeps/Godeps.json"))

      @godeps_data ||= begin
        data = JSON.parse(File.read(path("Godeps/Godeps.json")))
        { name: data["ImportPath"] }
      rescue JSON::ParserError
        nil
      end
    end

    def pom_xml_data
      return unless File.exist?(path("pom.xml"))

      @pom_xml_data ||= begin
        require "rexml/document"
        doc  = REXML::Document.new(File.read(path("pom.xml")))
        name = xml_text(doc, "//project/name") || xml_text(doc, "//project/artifactId")
        { name: name, license: xml_text(doc, "//project/licenses/license/name"),
          version: xml_text(doc, "//project/version") }
      rescue REXML::ParseException
        nil
      end
    end

    def xml_text(doc, xpath)
      REXML::XPath.first(doc, xpath)&.text
    end
  end
  # rubocop:enable Metrics/ClassLength
end
