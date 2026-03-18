# frozen_string_literal: true

RSpec.describe LicenseConflicts::LicenseNormalizer do
  describe ".normalize" do
    it "returns nil for nil input" do
      expect(described_class.normalize(nil)).to be_nil
    end

    it "returns the name unchanged when not recognised" do
      expect(described_class.normalize("SomeUnknownLicense")).to eq("SomeUnknownLicense")
    end

    # -------------------------------------------------------------------------
    # MIT
    # -------------------------------------------------------------------------
    it { expect(described_class.normalize("MIT")).to eq("MIT") }
    it { expect(described_class.normalize("Expat")).to eq("MIT") }
    it { expect(described_class.normalize("MIT License")).to eq("MIT") }

    # -------------------------------------------------------------------------
    # Apache 2.0
    # -------------------------------------------------------------------------
    it { expect(described_class.normalize("Apache-2.0")).to eq("Apache 2.0") }
    it { expect(described_class.normalize("apache-2.0")).to eq("Apache 2.0") }
    it { expect(described_class.normalize("Apache License, Version 2.0")).to eq("Apache 2.0") }
    it { expect(described_class.normalize("ASL 2.0")).to eq("Apache 2.0") }

    # -------------------------------------------------------------------------
    # New BSD / Simplified BSD
    # -------------------------------------------------------------------------
    it { expect(described_class.normalize("BSD-3-Clause")).to eq("New BSD") }
    it { expect(described_class.normalize("3-clause BSD")).to eq("New BSD") }
    it { expect(described_class.normalize("BSD-2-Clause")).to eq("Simplified BSD") }
    it { expect(described_class.normalize("FreeBSD")).to eq("Simplified BSD") }

    # -------------------------------------------------------------------------
    # GPL
    # -------------------------------------------------------------------------
    it { expect(described_class.normalize("GPL-2.0")).to eq("GPLv2") }
    it { expect(described_class.normalize("GPL-2.0-only")).to eq("GPLv2") }
    it { expect(described_class.normalize("GPL-3.0")).to eq("GPLv3") }
    it { expect(described_class.normalize("GPL-3.0-only")).to eq("GPLv3") }

    # -------------------------------------------------------------------------
    # LGPL
    # -------------------------------------------------------------------------
    it { expect(described_class.normalize("LGPL")).to eq("LGPL 3.0") }
    it { expect(described_class.normalize("LGPLv3")).to eq("LGPL 3.0") }
    it { expect(described_class.normalize("LGPL-3.0-only")).to eq("LGPL 3.0") }
    it { expect(described_class.normalize("GNU Lesser General Public License version 2.1")).to eq("LGPL 2.1") }
    it { expect(described_class.normalize("LGPL-2.1")).to eq("LGPL 2.1") }

    # -------------------------------------------------------------------------
    # MPL
    # -------------------------------------------------------------------------
    it { expect(described_class.normalize("MPL-1.1")).to eq("MPL 1.1") }
    it { expect(described_class.normalize("MPL-1.1+")).to eq("MPL 1.1") }
    it { expect(described_class.normalize("Mozilla Public License 1.1")).to eq("MPL 1.1") }
    it { expect(described_class.normalize("MPL-2.0")).to eq("MPL 2.0") }
    it { expect(described_class.normalize("Mozilla Public License 2.0")).to eq("MPL 2.0") }

    # -------------------------------------------------------------------------
    # AGPL
    # -------------------------------------------------------------------------
    it { expect(described_class.normalize("AGPL-3.0")).to eq("AGPL 3") }
    it { expect(described_class.normalize("AGPL-3.0-only")).to eq("AGPL 3") }
    it { expect(described_class.normalize("GNU Affero General Public License v3.0")).to eq("AGPL 3") }
    it { expect(described_class.normalize("AGPL-1.0+")).to eq("AGPL 1.0") }
    it { expect(described_class.normalize("AGPL-1.0")).to eq("AGPL 1.0") }

    # -------------------------------------------------------------------------
    # CDDL
    # -------------------------------------------------------------------------
    it { expect(described_class.normalize("CDDL-1.0")).to eq("CDDL 1.0") }
    it { expect(described_class.normalize("Common Development and Distribution License 1.0")).to eq("CDDL 1.0") }

    # -------------------------------------------------------------------------
    # Zlib
    # -------------------------------------------------------------------------
    it { expect(described_class.normalize("zlib/libpng license")).to eq("Zlib") }
    it { expect(described_class.normalize("zlib")).to eq("Zlib") }

    # -------------------------------------------------------------------------
    # OSL / AFL
    # -------------------------------------------------------------------------
    it { expect(described_class.normalize("OSL-3.0")).to eq("OSL 3.0") }
    it { expect(described_class.normalize("AFL-3.0")).to eq("AFL 3.0") }

    # -------------------------------------------------------------------------
    # EPL
    # -------------------------------------------------------------------------
    it { expect(described_class.normalize("EPL-1.0")).to eq("EPL 1.0") }
    it { expect(described_class.normalize("Eclipse Public License 1.0")).to eq("EPL 1.0") }
    it { expect(described_class.normalize("EPL-2.0")).to eq("EPL 2.0") }

    # -------------------------------------------------------------------------
    # ISC / Unlicense
    # -------------------------------------------------------------------------
    it { expect(described_class.normalize("ISC License")).to eq("ISC") }
    it { expect(described_class.normalize("The Unlicense")).to eq("Unlicense") }
  end
end
