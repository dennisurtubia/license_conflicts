# frozen_string_literal: true

require "license_conflicts/conflicts_map"

RSpec.describe LicenseConflicts::CONFLICTS_MAP do
  subject(:map) { described_class }

  all_licenses = LicenseConflicts::ALL_LICENSES

  # Mirrors LicenseConflicts::Finder#has_conflict?: a dependency conflicts with the
  # project when it appears in the project's conflict list.
  def conflict?(project, dependency)
    LicenseConflicts::CONFLICTS_MAP.fetch(project).include?(dependency)
  end

  describe "structural properties" do
    it "has exactly 16 keys" do
      expect(map.size).to eq(16)
    end

    it "uses only licenses from ALL_LICENSES as keys" do
      expect(map.keys).to all(satisfy { |license| all_licenses.include?(license) })
    end

    it "uses only licenses from ALL_LICENSES as values" do
      map.each_value do |conflicts|
        expect(conflicts).to all(satisfy { |license| all_licenses.include?(license) })
      end
    end

    it "never lists a license as conflicting with itself" do
      map.each do |project, conflicts|
        expect(conflicts).not_to include(project)
      end
    end

    it "covers all 16 graph licenses as keys" do
      expect(map.keys).to match_array(all_licenses)
    end
  end

  describe "non-conflicting cases (compatible -- must not be flagged)" do
    non_conflicting_cases = {
      "Apache 2.0" => ["MIT", "New BSD", "Simplified BSD", "Zlib"],
      # Apache-2.0 -> GPL-3.0 (licenses proposed for opencsv/Joda-Time, Table 4).
      "GPLv3" => ["Apache 2.0", "MIT", "New BSD", "Zlib", "MPL 2.0", "LGPL 2.1", "LGPL 3.0"],
      "GPLv2" => ["MIT", "New BSD", "MPL 2.0", "LGPL 2.1"],
      "AGPL 3" => ["GPLv3", "Apache 2.0", "MPL 2.0", "MIT"],
      # py2exe: non-transitive edge as the last edge; zlib/Apache from Section 4.1.
      "MPL 2.0" => ["MPL 1.1", "Apache 2.0", "Zlib"],
      "CDDL 1.0" => ["MPL 1.1"],
      "LGPL 3.0" => ["Apache 2.0"]
    }

    non_conflicting_cases.each do |project, dependencies|
      dependencies.each do |dependency|
        it "does not flag #{dependency} dependency in a #{project} project" do
          expect(conflict?(project, dependency)).to be(false)
        end
      end
    end
  end

  describe "conflicting cases (incompatible -- must be flagged)" do
    conflicting_cases = {
      # Nothing flows back into MIT.
      "MIT" => ["GPLv3", "Apache 2.0", "New BSD"],
      "Apache 2.0" => ["GPLv2", "LGPL 2.1", "GPLv3", "MPL 1.1"],
      # Shopware (Apache in a GPLv2 project) and the explicit zlib example of Section 4.1.
      "GPLv2" => ["Apache 2.0", "Zlib", "GPLv3", "MPL 1.1", "AGPL 3"],
      # "and vice versa" (CuteFlow/FileZilla) + CKEditor/HandBrake/Odoo cases.
      "GPLv3" => ["GPLv2", "MPL 1.1"],
      "LGPL 2.1" => ["Apache 2.0", "Zlib", "GPLv2", "MPL 1.1"],
      "LGPL 3.0" => ["MPL 1.1"],
      # Odoo (GPLv2 in an AGPL 3 project) + AGPL 1.0 + MPL 1.1.
      "AGPL 3" => ["GPLv2", "AGPL 1.0", "MPL 1.1"]
    }

    conflicting_cases.each do |project, dependencies|
      dependencies.each do |dependency|
        it "flags #{dependency} dependency in a #{project} project" do
          expect(conflict?(project, dependency)).to be(true)
        end
      end
    end
  end
end
