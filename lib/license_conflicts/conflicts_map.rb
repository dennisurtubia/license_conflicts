# frozen_string_literal: true

# Key: declared license of the EXAMINED PROJECT.
# Value: DEPENDENCY licenses that conflict with it, i.e. licenses that
# CANNOT be relicensed/combined under the project's license.
#
# Directional semantics (Kapitsaki et al. 2017, Definition 1 and Fig. 2):
#   conflict(project P, dependency D) <=> there is no path D -> P in the
#   article's compatibility graph.
#
# Documented assumptions/limitations:
# - Single-licensed projects only (OR/AND multi-licensing is out of scope).
# - Flattened names treated as the exact version ("only"): "GPLv2" = GPL-2.0-only, etc.
# - Canonical names as returned by LicenseFinder, normalized via LicenseNormalizer.
#
# rubocop:disable Metrics/ModuleLength -- hardcoded data map, long by nature.
module LicenseConflicts
  ALL_LICENSES = [
    "MIT",
    "Simplified BSD",
    "New BSD",
    "Zlib",
    "Apache 2.0",
    "AFL 3.0",
    "MPL 1.1",
    "MPL 2.0",
    "CDDL 1.0",
    "LGPL 2.1",
    "LGPL 3.0",
    "OSL 3.0",
    "GPLv2",
    "GPLv3",
    "AGPL 1.0",
    "AGPL 3"
  ].freeze

  CONFLICTS_MAP = {
    # Only MIT code (and public domain) can be relicensed as MIT.
    "MIT" => (ALL_LICENSES - ["MIT"]).freeze,

    "Simplified BSD" => (ALL_LICENSES - ["MIT", "Simplified BSD"]).freeze,

    "New BSD" => (ALL_LICENSES - ["MIT", "Simplified BSD", "New BSD"]).freeze,

    # No other license flows into Zlib in the article's graph.
    "Zlib" => (ALL_LICENSES - ["Zlib"]).freeze,

    # Permissive licenses (MIT, BSDs, Zlib) flow into Apache-2.0; everything else conflicts.
    "Apache 2.0" => [
      "AFL 3.0",
      "MPL 1.1",
      "MPL 2.0",
      "CDDL 1.0",
      "LGPL 2.1",
      "LGPL 3.0",
      "OSL 3.0",
      "GPLv2",
      "GPLv3",
      "AGPL 1.0",
      "AGPL 3"
    ].freeze,

    "AFL 3.0" => [
      "MPL 1.1",
      "MPL 2.0",
      "CDDL 1.0",
      "LGPL 2.1",
      "LGPL 3.0",
      "OSL 3.0",
      "GPLv2",
      "GPLv3",
      "AGPL 1.0",
      "AGPL 3"
    ].freeze,

    # No other license flows into MPL-1.1.
    "MPL 1.1" => (ALL_LICENSES - ["MPL 1.1"]).freeze,

    # MIT/BSDs (solid edge), Zlib/Apache-2.0 and MPL-1.1 (non-transitive edges as the
    # last edge of the path) flow into MPL-2.0. Article's py2exe case: MIT + MPL-1.1
    # are combinable under MPL-2.0.
    "MPL 2.0" => [
      "AFL 3.0",
      "CDDL 1.0",
      "LGPL 2.1",
      "LGPL 3.0",
      "OSL 3.0",
      "GPLv2",
      "GPLv3",
      "AGPL 1.0",
      "AGPL 3"
    ].freeze,

    # Only MPL-1.1 flows into CDDL-1.0 (CDDL is derived from MPL-1.1).
    "CDDL 1.0" => (ALL_LICENSES - ["MPL 1.1", "CDDL 1.0"]).freeze,

    # Zlib and Apache-2.0 do NOT flow into LGPL-2.1 (explicit incompatibility in the
    # article -- Shopware case). GPL cannot flow "back" into LGPL.
    "LGPL 2.1" => [
      "Zlib",
      "Apache 2.0",
      "AFL 3.0",
      "MPL 1.1",
      "CDDL 1.0",
      "LGPL 3.0",
      "OSL 3.0",
      "GPLv2",
      "GPLv3",
      "AGPL 1.0",
      "AGPL 3"
    ].freeze,

    # Apache-2.0 and Zlib flow into LGPL-3.0 (unlike LGPL-2.1).
    "LGPL 3.0" => [
      "AFL 3.0",
      "MPL 1.1",
      "CDDL 1.0",
      "LGPL 2.1",
      "OSL 3.0",
      "GPLv2",
      "GPLv3",
      "AGPL 1.0",
      "AGPL 3"
    ].freeze,

    "OSL 3.0" => [
      "MPL 1.1",
      "MPL 2.0",
      "CDDL 1.0",
      "LGPL 2.1",
      "LGPL 3.0",
      "GPLv2",
      "GPLv3",
      "AGPL 1.0",
      "AGPL 3"
    ].freeze,

    # Apache-2.0 and Zlib are incompatible with GPL-2.0 (explicit examples in the
    # article, Section 4.1 and Table 4). GPLv3 incompatible with GPLv2 "and vice versa".
    "GPLv2" => [
      "Zlib",
      "Apache 2.0",
      "AFL 3.0",
      "MPL 1.1",
      "CDDL 1.0",
      "LGPL 3.0",
      "OSL 3.0",
      "GPLv3",
      "AGPL 1.0",
      "AGPL 3"
    ].freeze,

    # Apache-2.0, Zlib, MPL-2.0 and the LGPLs flow into GPL-3.0.
    "GPLv3" => [
      "AFL 3.0",
      "MPL 1.1",
      "CDDL 1.0",
      "OSL 3.0",
      "GPLv2",
      "AGPL 1.0",
      "AGPL 3"
    ].freeze,

    # Exact-only assumption: nothing flows into AGPL-1.0 (in the article's graph the
    # node is AGPL-1.0+, with an outgoing edge only to AGPL-3.0).
    "AGPL 1.0" => (ALL_LICENSES - ["AGPL 1.0"]).freeze,

    # GPL-3.0 flows into AGPL-3.0 (GPLv3 clause 13); GPL-2.0 does not (Odoo case).
    "AGPL 3" => [
      "AFL 3.0",
      "MPL 1.1",
      "CDDL 1.0",
      "OSL 3.0",
      "GPLv2",
      "AGPL 1.0"
    ].freeze
  }.freeze
end
# rubocop:enable Metrics/ModuleLength
