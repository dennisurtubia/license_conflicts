# frozen_string_literal: true

module LicenseConflicts
  module LicenseNormalizer
    # Maps known license aliases and SPDX identifiers to the canonical names
    # used by LicenseFinder (i.e. what `dependency.licenses.first.name` returns).
    # Sources:
    #   - LicenseFinder definitions: lib/license_finder/license/definitions.rb
    #   - SPDX license list: https://spdx.org/licenses/
    ALIASES = {
      # -----------------------------------------------------------------------
      # MIT
      # -----------------------------------------------------------------------
      "MIT"                    => "MIT",
      "Expat"                  => "MIT",
      "MIT license"            => "MIT",
      "MIT License"            => "MIT",
      "MIT License (MIT)"      => "MIT",

      # -----------------------------------------------------------------------
      # Apache 2.0
      # -----------------------------------------------------------------------
      "Apache 2.0"                            => "Apache 2.0",
      "Apache-2.0"                            => "Apache 2.0",
      "apache-2.0"                            => "Apache 2.0",
      "Apache 2"                              => "Apache 2.0",
      "Apache Software License"               => "Apache 2.0",
      "Apache License 2.0"                    => "Apache 2.0",
      "Apache License Version 2.0"            => "Apache 2.0",
      "Apache Public License 2.0"             => "Apache 2.0",
      "Apache Software License, Version 2.0"  => "Apache 2.0",
      "Apache Software License - Version 2.0" => "Apache 2.0",
      "Apache License, Version 2.0"           => "Apache 2.0",
      "ASL 2.0"                               => "Apache 2.0",
      "ASF 2.0"                               => "Apache 2.0",

      # -----------------------------------------------------------------------
      # Apache 1.1
      # -----------------------------------------------------------------------
      "Apache 1.1"                            => "Apache 1.1",
      "Apache-1.1"                            => "Apache 1.1",
      "APACHE 1.1"                            => "Apache 1.1",
      "Apache License 1.1"                    => "Apache 1.1",
      "Apache License Version 1.1"            => "Apache 1.1",
      "Apache Public License 1.1"             => "Apache 1.1",
      "Apache Software License, Version 1.1"  => "Apache 1.1",
      "Apache Software License - Version 1.1" => "Apache 1.1",
      "Apache License, Version 1.1"           => "Apache 1.1",
      "ASL 1.1"                               => "Apache 1.1",
      "ASF 1.1"                               => "Apache 1.1",

      # -----------------------------------------------------------------------
      # New BSD (BSD 3-Clause)
      # -----------------------------------------------------------------------
      "New BSD"                  => "New BSD",
      "NewBSD"                   => "New BSD",
      "BSD-3-Clause"             => "New BSD",
      "BSD3"                     => "New BSD",
      "BSD 3"                    => "New BSD",
      "BSD-3"                    => "New BSD",
      "Modified BSD"             => "New BSD",
      "3-clause BSD"             => "New BSD",
      "3-Clause BSD License"     => "New BSD",
      "BSD 3-Clause"             => "New BSD",
      "BSD 3-Clause License"     => "New BSD",
      "BSD 3-clause New License" => "New BSD",
      "New BSD License"          => "New BSD",
      "BSD New license"          => "New BSD",
      "BSD License 3"            => "New BSD",
      "BSD Licence 3"            => "New BSD",

      # -----------------------------------------------------------------------
      # Simplified BSD (BSD 2-Clause)
      # -----------------------------------------------------------------------
      "Simplified BSD"         => "Simplified BSD",
      "BSD-2-Clause"           => "Simplified BSD",
      "BSD-2"                  => "Simplified BSD",
      "FreeBSD"                => "Simplified BSD",
      "2-clause BSD"           => "Simplified BSD",
      "BSD 2-Clause"           => "Simplified BSD",
      "BSD 2-Clause License"   => "Simplified BSD",

      # -----------------------------------------------------------------------
      # GPLv2
      # -----------------------------------------------------------------------
      "GPLv2"                                  => "GPLv2",
      "GPL-2.0"                                => "GPLv2",
      "GPL-2.0-only"                           => "GPLv2",
      "GPL-2.0+"                               => "GPLv2",
      "GPL V2"                                 => "GPLv2",
      "gpl-v2"                                 => "GPLv2",
      "GPL 2.0"                                => "GPLv2",
      "GNU GENERAL PUBLIC LICENSE Version 2"   => "GPLv2",

      # -----------------------------------------------------------------------
      # GPLv3
      # -----------------------------------------------------------------------
      "GPLv3"                                  => "GPLv3",
      "GPL-3.0"                                => "GPLv3",
      "GPL-3.0-only"                           => "GPLv3",
      "GPL-3.0+"                               => "GPLv3",
      "GPL V3"                                 => "GPLv3",
      "gpl-v3"                                 => "GPLv3",
      "GPL 3.0"                                => "GPLv3",
      "GNU GENERAL PUBLIC LICENSE Version 3"   => "GPLv3",

      # -----------------------------------------------------------------------
      # LGPL 3.0
      # -----------------------------------------------------------------------
      "LGPL"         => "LGPL 3.0",
      "LGPL 3.0"     => "LGPL 3.0",
      "LGPL-3"       => "LGPL 3.0",
      "LGPLv3"       => "LGPL 3.0",
      "LGPL-3.0"     => "LGPL 3.0",
      "LGPL-3.0-only" => "LGPL 3.0",

      # -----------------------------------------------------------------------
      # LGPL 2.1
      # -----------------------------------------------------------------------
      "LGPL 2.1"                                    => "LGPL 2.1",
      "LGPL-2.1"                                    => "LGPL 2.1",
      "LGPL-2.1-only"                               => "LGPL 2.1",
      "LGPL v2.1"                                   => "LGPL 2.1",
      "GNU Lesser General Public License 2.1"       => "LGPL 2.1",
      "GNU Lesser General Public License version 2.1" => "LGPL 2.1",

      # -----------------------------------------------------------------------
      # MPL 1.1
      # -----------------------------------------------------------------------
      "MPL 1.1"                               => "MPL 1.1",
      "MPL-1.1"                               => "MPL 1.1",
      "MPL-1.1+"                              => "MPL 1.1",
      "Mozilla 1.1"                           => "MPL 1.1",
      "Mozilla Public License 1.1"            => "MPL 1.1",
      "Mozilla Public License, Version 1.1"   => "MPL 1.1",
      "Mozilla Public License version 1.1"    => "MPL 1.1",

      # -----------------------------------------------------------------------
      # MPL 2.0
      # -----------------------------------------------------------------------
      "MPL 2.0"                               => "MPL 2.0",
      "MPL-2.0"                               => "MPL 2.0",
      "Mozilla 2.0"                           => "MPL 2.0",
      "Mozilla Public License 2.0"            => "MPL 2.0",
      "Mozilla Public License, Version 2.0"   => "MPL 2.0",
      "Mozilla Public License version 2.0"    => "MPL 2.0",

      # -----------------------------------------------------------------------
      # AGPL 3
      # -----------------------------------------------------------------------
      "AGPL 3"                                        => "AGPL 3",
      "AGPL3"                                         => "AGPL 3",
      "AGPL-3.0"                                      => "AGPL 3",
      "AGPL-3.0-only"                                 => "AGPL 3",
      "AGPL 3.0"                                      => "AGPL 3",
      "GNU Affero General Public License v3.0"        => "AGPL 3",
      "GNU Affero General Public License, Version 3"  => "AGPL 3",

      # -----------------------------------------------------------------------
      # AGPL 1.0 (older version, not in LicenseFinder definitions but seen in the wild)
      # -----------------------------------------------------------------------
      "AGPL 1.0"   => "AGPL 1.0",
      "AGPL-1.0"   => "AGPL 1.0",
      "AGPL-1.0+"  => "AGPL 1.0",
      "AGPL1"      => "AGPL 1.0",

      # -----------------------------------------------------------------------
      # CDDL 1.0
      # -----------------------------------------------------------------------
      "CDDL 1.0"                                                       => "CDDL 1.0",
      "CDDL-1.0"                                                       => "CDDL 1.0",
      "Common Development and Distribution License 1.0"                => "CDDL 1.0",
      "Common Development and Distribution License (CDDL) v1.0"       => "CDDL 1.0",
      "COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL) Version 1.0" => "CDDL 1.0",

      # -----------------------------------------------------------------------
      # AFL 3.0
      # -----------------------------------------------------------------------
      "AFL 3.0"                               => "AFL 3.0",
      "AFL-3.0"                               => "AFL 3.0",
      "Academic Free License 3.0"             => "AFL 3.0",
      "Academic Free License, Version 3.0"    => "AFL 3.0",

      # -----------------------------------------------------------------------
      # OSL 3.0
      # -----------------------------------------------------------------------
      "OSL 3.0"                               => "OSL 3.0",
      "OSL-3.0"                               => "OSL 3.0",
      "Open Software License 3.0"             => "OSL 3.0",
      "Open Software License, Version 3.0"    => "OSL 3.0",

      # -----------------------------------------------------------------------
      # ISC
      # -----------------------------------------------------------------------
      "ISC"         => "ISC",
      "ISC License" => "ISC",

      # -----------------------------------------------------------------------
      # Zlib
      # -----------------------------------------------------------------------
      "Zlib"                => "Zlib",
      "zlib"                => "Zlib",
      "zlib/libpng license" => "Zlib",
      "zlib License"        => "Zlib",

      # -----------------------------------------------------------------------
      # Unlicense
      # -----------------------------------------------------------------------
      "Unlicense"     => "Unlicense",
      "The Unlicense" => "Unlicense",

      # -----------------------------------------------------------------------
      # EPL 1.0
      # -----------------------------------------------------------------------
      "EPL 1.0"                          => "EPL 1.0",
      "EPL-1.0"                          => "EPL 1.0",
      "Eclipse 1.0"                      => "EPL 1.0",
      "Eclipse Public License 1.0"       => "EPL 1.0",
      "Eclipse Public License - v 1.0"   => "EPL 1.0",

      # -----------------------------------------------------------------------
      # EPL 2.0
      # -----------------------------------------------------------------------
      "EPL 2.0"                          => "EPL 2.0",
      "EPL-2.0"                          => "EPL 2.0",
      "Eclipse 2.0"                      => "EPL 2.0",
      "Eclipse Public License 2.0"       => "EPL 2.0",
      "Eclipse Public License - v 2.0"   => "EPL 2.0"
    }.freeze

    # Returns the canonical license name for the given string.
    # If the name is not recognised, it is returned as-is so the caller can
    # decide what to do (e.g. raise "not mapped").
    def self.normalize(name)
      return nil if name.nil?

      ALIASES.fetch(name, name)
    end
  end
end
