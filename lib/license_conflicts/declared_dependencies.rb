# frozen_string_literal: true

require "json"
require "set"

module LicenseConflicts
  # Names of the dependencies a project declares in its own manifests at the project root,
  # i.e. its direct dependencies. Every supported manifest present contributes to the set.
  class DeclaredDependencies
    # Manifest (glob relative to the project root) => reader returning the declared names, or
    # nil when the file cannot be parsed. Godeps/Godeps.json is not listed: it pins every
    # vendored package without telling direct from transitive ones.
    READERS = {
      "package.json" => :json_manifest_names,
      "bower.json" => :json_manifest_names,
      "*.gemspec" => :gemspec_names,
      "Gemfile" => :gemfile_names,
      "requirements.txt" => :requirements_names,
      "setup.cfg" => :setup_cfg_names,
      "pyproject.toml" => :pyproject_names,
      "go.mod" => :go_mod_names,
      "pom.xml" => :pom_names
    }.freeze

    # Some registries treat names differing only in case or in `-`, `_` and `.` as the same
    # package, and package managers may report a name normalized differently from how the
    # manifest spells it; names are compared by this key.
    def self.key(name)
      name.to_s.downcase.gsub(/[-_.]+/, "-")
    end

    def initialize(root = ".")
      @root = root
    end

    # Set of normalized names, or nil when no readable manifest is present (direct and
    # transitive dependencies cannot be told apart).
    def names
      return @names if defined?(@names)

      declared = READERS.flat_map do |pattern, reader|
        Dir.glob(File.join(@root, pattern)).map { |file| send(reader, File.read(file)) }
      end.compact
      @names = declared.empty? ? nil : declared.flatten.to_set { |name| self.class.key(name) }
    end

    def include?(name)
      names&.include?(self.class.key(name))
    end

    private

    # Requirement specifiers such as `requests[security]>=2.0; python_version > "3"`.
    def requirement_name(specifier)
      specifier[/\A\s*([A-Za-z0-9][A-Za-z0-9._-]*)/, 1]
    end

    def json_manifest_names(content)
      data = JSON.parse(content)
      return [] unless data.is_a?(Hash)

      %w[dependencies devDependencies].flat_map { |field| data[field].is_a?(Hash) ? data[field].keys : [] }
    rescue JSON::ParserError
      nil
    end

    def gemspec_names(content)
      content.scan(/\.add_(?:runtime_|development_)?dependency\s*\(?\s*["']([^"']+)["']/).flatten
    end

    def gemfile_names(content)
      content.scan(/^\s*gem\s*\(?\s*["']([^"']+)["']/).flatten
    end

    def requirements_names(content)
      content.each_line.filter_map do |line|
        line = line.sub(/(?:\A|\s)#(?!egg=).*/, "").strip
        next line[/#egg=([A-Za-z0-9._-]+)/, 1] if line.include?("://")
        next if line.empty? || line.start_with?("-")

        requirement_name(line)
      end
    end

    def setup_cfg_names(content)
      value = content[/^install_requires\s*=(.*(?:\n[ \t]+.*)*)/, 1]
      return [] unless value

      value.split("\n").filter_map { |line| requirement_name(line) }
    end

    def pyproject_names(content)
      require "tomlrb"
      data = Tomlrb.parse(content)
      pep621 = Array(data.dig("project", "dependencies")).filter_map { |specifier| requirement_name(specifier) }
      pep621 + poetry_names(data.dig("tool", "poetry") || {})
    rescue LoadError, Tomlrb::ParseError
      nil
    end

    def poetry_names(poetry)
      groups = (poetry["group"] || {}).values.map { |group| group["dependencies"] }
      tables = [poetry["dependencies"], poetry["dev-dependencies"], *groups]
      tables.flat_map { |table| table.is_a?(Hash) ? table.keys : [] } - ["python"]
    end

    # `require` directives, single or in a block, except the ones marked `// indirect`.
    def go_mod_names(content)
      block_lines = content.scan(/^require\s*\(\s*\n(.*?)^\)/m).flatten.flat_map(&:lines)
      single_lines = content.scan(/^require\s+([^\s(].*)$/).flatten
      (block_lines + single_lines).reject { |line| line.include?("// indirect") }
                                  .filter_map { |line| line.strip.split.first unless line.strip.start_with?("//") }
    end

    def pom_names(content)
      require "rexml/document"
      path = %w[project dependencies dependency].map { |tag| "*[local-name()='#{tag}']" }.join("/")
      REXML::XPath.match(REXML::Document.new(content), "/#{path}").flat_map { |node| pom_coordinates(node) }
    rescue REXML::ParseException
      nil
    end

    # Both `artifactId` and `groupId:artifactId`, since the package manager may report either.
    def pom_coordinates(dependency)
      artifact, group = %w[artifactId groupId].map { |tag| REXML::XPath.first(dependency, "*[local-name()='#{tag}']")&.text }
      return [] unless artifact

      group ? [artifact, "#{group}:#{artifact}"] : [artifact]
    end
  end
end
