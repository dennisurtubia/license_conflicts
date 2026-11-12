# frozen_string_literal: true

require "set"

RSpec.describe LicenseConflicts::Finder do
  let(:aggregator) { instance_double(LicenseFinder::LicenseAggregator) }
  let(:metadata) { instance_double(LicenseConflicts::ProjectMetadata, name: "my-app", license: "MIT") }
  let(:direct) { Set["react", "gpl-lib"] }
  let(:packages) do
    [package("my-app", "MIT"), package("react", "MIT"), package("gpl-lib", "GPLv3"),
     package("transitive-gpl", "GPLv3"), package("transitive-mit", "MIT")]
  end

  subject(:finder) { described_class.new }

  def package(name, license, version = "1.0.0", install_path: nil)
    double("package #{name}@#{version}",
           name: name, version: version, install_path: install_path, licenses: [double(name: license)])
  end

  def installed(path, version)
    copy = instance_double(LicenseConflicts::ProjectMetadata, version: version)
    allow(LicenseConflicts::ProjectMetadata).to receive(:new).with(path).and_return(copy)
  end

  before do
    allow(LicenseFinder::LicenseAggregator).to receive(:new).and_return(aggregator)
    allow(aggregator).to receive(:unapproved).and_return(packages)
    allow(LicenseConflicts::ProjectMetadata).to receive(:new).with(no_args).and_return(metadata)
    allow(LicenseConflicts::DeclaredDependencies).to receive(:new)
      .and_return(LicenseConflicts::DeclaredDependencies.new.tap { |d| d.instance_variable_set(:@names, keys) })
  end

  let(:keys) { direct&.to_set { |name| LicenseConflicts::DeclaredDependencies.key(name) } }

  describe "#dependencies_count" do
    it "counts only the declared direct dependencies, excluding the project itself" do
      expect(finder.dependencies_count).to eq(2)
    end

    context "when the project has no supported manifest" do
      let(:direct) { nil }

      it "counts every dependency LicenseFinder reports" do
        expect(finder.dependencies_count).to eq(4)
      end
    end

    context "when a declared dependency was not resolved by LicenseFinder" do
      let(:direct) { Set["react", "gpl-lib", "never-installed"] }

      it "counts only what was resolved" do
        expect(finder.dependencies_count).to eq(2)
      end
    end
  end

  context "when LicenseFinder reports a direct dependency in several versions" do
    let(:packages) do
      [package("react", "MIT", "18.0.0"),
       package("gpl-lib", "GPLv3", "1.0.0", install_path: "/app/deps/gpl-lib"),
       package("gpl-lib", "MIT", "2.0.0", install_path: "/app/deps/gpl-lib")]
    end

    it "keeps the version found at the install path" do
      installed("/app/deps/gpl-lib", "2.0.0")

      expect(finder.dependencies_count).to eq(2)
      expect(finder.find_conflicts).to be_empty
    end

    it "keeps the first one when the installed version is unknown" do
      installed("/app/deps/gpl-lib", nil)

      expect(finder.dependencies_count).to eq(2)
      expect(finder.find_conflicts.map(&:version)).to eq(["1.0.0"])
    end
  end

  describe "#find_conflicts" do
    it "reports conflicts among direct dependencies only" do
      expect(finder.find_conflicts.map(&:name)).to eq(["gpl-lib"])
    end

    context "when the project has no supported manifest" do
      let(:direct) { nil }

      it "checks every dependency LicenseFinder reports" do
        expect(finder.find_conflicts.map(&:name)).to contain_exactly("gpl-lib", "transitive-gpl")
      end
    end
  end

  describe "#project_license" do
    it "keeps reading the examined project from LicenseFinder" do
      allow(aggregator).to receive(:unapproved).and_return([package("my-app", "Apache 2.0")])

      expect(finder.project_license).to eq("Apache 2.0")
    end
  end
end
