# frozen_string_literal: true

require "tmpdir"

RSpec.describe LicenseConflicts::ProjectMetadata do
  around do |example|
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) { example.run }
    end
  end

  subject(:metadata) { described_class.new }

  describe "Node.js (package.json)" do
    before do
      File.write("package.json", JSON.generate("name" => "my-app", "license" => "MIT"))
    end

    it "reads name" do
      expect(metadata.name).to eq("my-app")
    end

    it "reads license" do
      expect(metadata.license).to eq("MIT")
    end
  end

  describe "Node.js (package.json) — invalid JSON" do
    before { File.write("package.json", "{ invalid json") }

    it "does not crash and falls back to directory name" do
      expect { metadata.name }.not_to raise_error
    end
  end

  describe "Bower (bower.json)" do
    before do
      File.write("bower.json", JSON.generate("name" => "my-bower-app", "license" => "Apache-2.0"))
    end

    it "reads name" do
      expect(metadata.name).to eq("my-bower-app")
    end

    it "reads license" do
      expect(metadata.license).to eq("Apache-2.0")
    end
  end

  describe "Bower (bower.json) — invalid JSON" do
    before { File.write("bower.json", "{ invalid") }

    it "does not crash" do
      expect { metadata.name }.not_to raise_error
    end
  end

  describe "Ruby (*.gemspec)" do
    before do
      File.write("my_gem.gemspec", <<~GEMSPEC)
        Gem::Specification.new do |spec|
          spec.name    = "my_gem"
          spec.license = "MIT"
        end
      GEMSPEC
    end

    it "reads name" do
      expect(metadata.name).to eq("my_gem")
    end

    it "reads license" do
      expect(metadata.license).to eq("MIT")
    end
  end

  describe "Python (setup.cfg)" do
    before do
      File.write("setup.cfg", <<~CFG)
        [metadata]
        name = my-python-app
        license = GPL-3.0
      CFG
    end

    it "reads name" do
      expect(metadata.name).to eq("my-python-app")
    end

    it "reads license" do
      expect(metadata.license).to eq("GPL-3.0")
    end
  end

  describe "Python (pyproject.toml — PEP 621)" do
    before do
      File.write("pyproject.toml", <<~TOML)
        [project]
        name = "my-pep621-app"
        license = "MIT"
      TOML
    end

    it "reads name" do
      expect(metadata.name).to eq("my-pep621-app")
    end

    it "reads license" do
      expect(metadata.license).to eq("MIT")
    end
  end

  describe "Python (pyproject.toml — PEP 621 inline table license)" do
    before do
      File.write("pyproject.toml", <<~TOML)
        [project]
        name = "my-pep621-app"
        license = {text = "Apache-2.0"}
      TOML
    end

    it "extracts license from inline table" do
      expect(metadata.license).to eq("Apache-2.0")
    end
  end

  describe "Python (pyproject.toml — Poetry)" do
    before do
      File.write("pyproject.toml", <<~TOML)
        [tool.poetry]
        name = "my-poetry-app"
        license = "MIT"
      TOML
    end

    it "reads name" do
      expect(metadata.name).to eq("my-poetry-app")
    end

    it "reads license" do
      expect(metadata.license).to eq("MIT")
    end
  end

  describe "Go modules (go.mod)" do
    before do
      File.write("go.mod", <<~GOMOD)
        module github.com/example/my-go-app

        go 1.21
      GOMOD
    end

    it "reads module path as name" do
      expect(metadata.name).to eq("github.com/example/my-go-app")
    end

    it "returns nil for license (go.mod has no license field)" do
      expect(metadata.license).to be_nil
    end
  end

  describe "Godep (Godeps/Godeps.json)" do
    before do
      Dir.mkdir("Godeps")
      File.write("Godeps/Godeps.json", JSON.generate("ImportPath" => "github.com/example/my-godep-app"))
    end

    it "reads import path as name" do
      expect(metadata.name).to eq("github.com/example/my-godep-app")
    end

    it "returns nil for license" do
      expect(metadata.license).to be_nil
    end
  end

  describe "Godep (Godeps/Godeps.json) — invalid JSON" do
    before do
      Dir.mkdir("Godeps")
      File.write("Godeps/Godeps.json", "{ invalid")
    end

    it "does not crash" do
      expect { metadata.name }.not_to raise_error
    end
  end

  describe "Java Maven (pom.xml)" do
    before do
      File.write("pom.xml", <<~XML)
        <project>
          <name>my-maven-app</name>
          <artifactId>my-maven-app</artifactId>
          <licenses>
            <license>
              <name>Apache-2.0</name>
            </license>
          </licenses>
        </project>
      XML
    end

    it "reads name" do
      expect(metadata.name).to eq("my-maven-app")
    end

    it "reads license" do
      expect(metadata.license).to eq("Apache-2.0")
    end
  end

  describe "Java Maven (pom.xml) — uses artifactId when name is absent" do
    before do
      File.write("pom.xml", <<~XML)
        <project>
          <artifactId>my-artifact</artifactId>
          <licenses>
            <license><name>MIT</name></license>
          </licenses>
        </project>
      XML
    end

    it "falls back to artifactId" do
      expect(metadata.name).to eq("my-artifact")
    end
  end

  describe "Java Maven (pom.xml) — invalid XML" do
    before { File.write("pom.xml", "<project><unclosed>") }

    it "does not crash" do
      expect { metadata.name }.not_to raise_error
    end
  end

  describe "priority order" do
    before do
      File.write("package.json", JSON.generate("name" => "npm-name", "license" => "MIT"))
      File.write("bower.json",   JSON.generate("name" => "bower-name", "license" => "GPL-3.0"))
    end

    it "prefers package.json name over bower.json" do
      expect(metadata.name).to eq("npm-name")
    end

    it "prefers package.json license over bower.json" do
      expect(metadata.license).to eq("MIT")
    end
  end

  describe "fallback when no metadata file is present" do
    it "returns the current directory name" do
      expect(metadata.name).to eq(File.basename(Dir.pwd))
    end

    it "returns nil for license" do
      expect(metadata.license).to be_nil
    end
  end
end
