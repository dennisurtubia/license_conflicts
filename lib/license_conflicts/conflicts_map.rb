# frozen_string_literal: true

# All license names in this file use the canonical form returned by
# LicenseFinder (dependency.licenses.first.name). Input is normalised via
# LicenseNormalizer before any lookup, so SPDX IDs and common aliases are
# handled transparently.

module LicenseConflicts
  APACHE2_CONFLICTS = [
    "MIT",
    "New BSD",
    "Simplified BSD",
    "Zlib",
    "MPL 1.1",
    "CDDL 1.0",
    "AGPL 1.0"
  ].freeze

  NEW_BSD_CONFLICTS = [
    "MIT",
    "Simplified BSD",
    "Zlib",
    "MPL 1.1",
    "CDDL 1.0",
    "AGPL 1.0"
  ].freeze

  GPL2_CONFLICTS = [
    "MIT",
    "Simplified BSD",
    "New BSD",
    "Apache 2.0",
    "Zlib",
    "AFL 3.0",
    "MPL 1.1",
    "MPL 2.0",
    "CDDL 1.0",
    "LGPL 2.1",
    "LGPL 3.0",
    "OSL 3.0",
    "AGPL 1.0"
  ].freeze

  GPL3_CONFLICTS = [
    "MIT",
    "Simplified BSD",
    "New BSD",
    "Apache 2.0",
    "Zlib",
    "AFL 3.0",
    "MPL 1.1",
    "MPL 2.0",
    "CDDL 1.0",
    "LGPL 2.1",
    "LGPL 3.0",
    "OSL 3.0",
    "GPLv2",
    "AGPL 1.0"
  ].freeze

  MPL2_CONFLICTS = [
    "MIT",
    "Simplified BSD",
    "New BSD",
    "Apache 2.0",
    "Zlib",
    "AFL 3.0",
    "MPL 1.1",
    "CDDL 1.0",
    "LGPL 3.0",
    "OSL 3.0",
    "AGPL 1.0"
  ].freeze

  SIMPLIFIED_BSD_CONFLICTS = [
    "MIT",
    "Zlib",
    "MPL 1.1",
    "CDDL 1.0",
    "AGPL 1.0"
  ].freeze

  CONFLICTS_MAP = {
    "MIT" => [
      "Zlib",
      "MPL 1.1",
      "CDDL 1.0",
      "AGPL 1.0"
    ],
    "Simplified BSD" => SIMPLIFIED_BSD_CONFLICTS,
    "New BSD"        => NEW_BSD_CONFLICTS,
    "Apache 2.0"     => APACHE2_CONFLICTS,
    "Zlib" => [
      "MIT",
      "New BSD",
      "Simplified BSD",
      "MPL 1.1",
      "CDDL 1.0",
      "AGPL 1.0"
    ],
    "AFL 3.0" => [
      "MIT",
      "Simplified BSD",
      "New BSD",
      "Apache 2.0",
      "MPL 1.1",
      "MPL 2.0",
      "CDDL 1.0",
      "LGPL 2.1",
      "LGPL 3.0",
      "GPLv2",
      "GPLv3",
      "AGPL 3",
      "Zlib",
      "AGPL 1.0"
    ],
    "MPL 1.1" => [
      "MIT",
      "Simplified BSD",
      "New BSD",
      "Apache 2.0",
      "Zlib",
      "AFL 3.0",
      "LGPL 3.0",
      "OSL 3.0",
      "AGPL 1.0"
    ],
    "MPL 2.0"    => MPL2_CONFLICTS,
    "CDDL 1.0" => [
      "MIT",
      "Simplified BSD",
      "New BSD",
      "Apache 2.0",
      "Zlib",
      "AFL 3.0",
      "MPL 1.1",
      "MPL 2.0",
      "LGPL 2.1",
      "LGPL 3.0",
      "OSL 3.0",
      "GPLv2",
      "GPLv3",
      "AGPL 3",
      "AGPL 1.0"
    ],
    "LGPL 2.1" => [
      "MIT",
      "Simplified BSD",
      "New BSD",
      "Apache 2.0",
      "Zlib",
      "AFL 3.0",
      "MPL 1.1",
      "MPL 2.0",
      "CDDL 1.0",
      "OSL 3.0",
      "AGPL 1.0"
    ],
    "OSL 3.0" => [
      "MIT",
      "Simplified BSD",
      "New BSD",
      "Apache 2.0",
      "Zlib",
      "AFL 3.0",
      "MPL 1.1",
      "MPL 2.0",
      "CDDL 1.0",
      "LGPL 2.1",
      "LGPL 3.0",
      "GPLv2",
      "GPLv3",
      "AGPL 3",
      "AGPL 1.0"
    ],
    "GPLv2"  => GPL2_CONFLICTS,
    "GPLv3"  => GPL3_CONFLICTS,
    "AGPL 3" => [
      "MIT",
      "Simplified BSD",
      "New BSD",
      "Apache 2.0",
      "Zlib",
      "AFL 3.0",
      "MPL 1.1",
      "MPL 2.0",
      "CDDL 1.0",
      "LGPL 2.1",
      "LGPL 3.0",
      "OSL 3.0",
      "GPLv2",
      "GPLv3",
      "AGPL 1.0"
    ],
    "AGPL 1.0" => [
      "MIT",
      "Simplified BSD",
      "New BSD",
      "Apache 2.0",
      "Zlib",
      "AFL 3.0",
      "MPL 1.1",
      "MPL 2.0",
      "CDDL 1.0",
      "LGPL 2.1",
      "LGPL 3.0",
      "OSL 3.0",
      "GPLv2",
      "GPLv3"
    ]
  }.freeze
end
