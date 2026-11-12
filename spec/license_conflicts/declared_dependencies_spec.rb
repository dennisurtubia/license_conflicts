# frozen_string_literal: true

require "fileutils"
require "tmpdir"

RSpec.describe LicenseConflicts::DeclaredDependencies do
  around do |example|
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) { example.run }
    end
  end

  subject(:declared) { described_class.new }

  def names
    declared.names&.to_a
  end

  describe ".key" do
    it "ignores case and separator differences" do
      expect(described_class.key("Typing_Extensions")).to eq(described_class.key("typing-extensions"))
      expect(described_class.key("zope.interface")).to eq(described_class.key("zope-interface"))
    end
  end

  describe "package.json and bower.json" do
    it "reads dependencies and devDependencies of both manifests" do
      File.write("package.json", JSON.generate("dependencies" => { "react" => "^18.0.0" },
                                               "devDependencies" => { "jest" => "^29.0.0" }))
      File.write("bower.json", JSON.generate("dependencies" => { "jquery" => "~3.0", "react" => "*" }))

      expect(names).to contain_exactly("react", "jest", "jquery")
    end

    it "ignores peer and optional dependencies and malformed fields" do
      File.write("package.json", JSON.generate("dependencies" => %w[not a hash],
                                               "peerDependencies" => { "react" => "*" },
                                               "optionalDependencies" => { "fsevents" => "*" }))

      expect(names).to be_empty
    end
  end

  describe "Gemfile and *.gemspec" do
    it "reads gem declarations and runtime and development dependencies" do
      File.write("Gemfile", "source 'https://rubygems.org'\ngemspec\ngem \"rake\", \"~> 13.0\"\n  gem('pry')\n")
      File.write("my_gem.gemspec", <<~GEMSPEC)
        Gem::Specification.new do |spec|
          spec.add_dependency "thor", "~> 1.5"
          spec.add_runtime_dependency("csv")
          spec.add_development_dependency 'rspec'
        end
      GEMSPEC

      expect(names).to contain_exactly("rake", "pry", "thor", "csv", "rspec")
    end
  end

  describe "requirements.txt" do
    it "reads requirement names and skips comments, options and plain URLs" do
      File.write("requirements.txt", <<~REQS)
        # tools
        Django>=4.2  # web
        requests[security]==2.31; python_version > "3.8"
        -r dev.txt
        --index-url https://example.org/simple
        git+https://github.com/org/repo.git#egg=my_pkg
        https://example.org/archive.tar.gz
      REQS

      expect(names).to contain_exactly("django", "requests", "my-pkg")
    end
  end

  describe "setup.cfg" do
    it "reads install_requires" do
      File.write("setup.cfg", "[metadata]\nname = app\n\n[options]\ninstall_requires =\n    click>=8\n    PyYAML\n")

      expect(names).to contain_exactly("click", "pyyaml")
    end
  end

  describe "pyproject.toml" do
    it "reads PEP 621 dependencies" do
      File.write("pyproject.toml", "[project]\nname = \"app\"\ndependencies = [\"httpx>=0.27\", \"rich\"]\n")

      expect(names).to contain_exactly("httpx", "rich")
    end

    it "reads Poetry dependency tables, without python itself" do
      File.write("pyproject.toml", <<~TOML)
        [tool.poetry.dependencies]
        python = "^3.11"
        fastapi = "*"
        [tool.poetry.dev-dependencies]
        pytest = "*"
        [tool.poetry.group.lint.dependencies]
        ruff = "*"
      TOML

      expect(names).to contain_exactly("fastapi", "pytest", "ruff")
    end
  end

  describe "go.mod" do
    it "reads required modules, except indirect ones" do
      File.write("go.mod", <<~GOMOD)
        module example.com/app

        require github.com/spf13/cobra v1.8.0

        require (
          // pinned for CVE-2024-0001
          golang.org/x/text v0.14.0
          github.com/inconshreveable/mousetrap v1.1.0 // indirect
        )
      GOMOD

      expect(names).to contain_exactly(described_class.key("github.com/spf13/cobra"),
                                       described_class.key("golang.org/x/text"))
    end
  end

  describe "pom.xml" do
    it "reads dependencies by artifactId and groupId:artifactId, with or without a namespace" do
      File.write("pom.xml", <<~XML)
        <project xmlns="http://maven.apache.org/POM/4.0.0">
          <dependencies>
            <dependency><groupId>junit</groupId><artifactId>junit</artifactId></dependency>
          </dependencies>
          <dependencyManagement>
            <dependencies>
              <dependency><groupId>org.slf4j</groupId><artifactId>slf4j-api</artifactId></dependency>
            </dependencies>
          </dependencyManagement>
        </project>
      XML

      expect(declared).to include("junit")
      expect(declared).to include("junit:junit")
      expect(declared).not_to include("slf4j-api")
    end
  end

  describe "#include?" do
    it "matches names regardless of case and separators" do
      File.write("requirements.txt", "typing_extensions\n")

      expect(declared).to include("typing-extensions")
    end
  end

  describe "when no manifest can be read" do
    it "is nil without a supported manifest" do
      FileUtils.mkdir_p("Godeps")
      File.write("Godeps/Godeps.json", JSON.generate("Deps" => [{ "ImportPath" => "github.com/a/b" }]))

      expect(declared.names).to be_nil
      expect(declared).not_to include("github.com/a/b")
    end

    it "is nil when the only manifest is invalid" do
      File.write("package.json", "{ invalid")

      expect(declared.names).to be_nil
    end
  end
end
