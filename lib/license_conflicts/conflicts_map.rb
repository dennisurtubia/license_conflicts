# frozen_string_literal: true

module LicenseConflicts
  APACHE2_CONFLICTS = [
    'MIT',
    'New BSD',
    'Simplified BSD',
    'zlib/libpng license',
    'Mozilla Public License 1.1',
    'Common Development and Distribution License 1.0',
    'AGPL-1.0+'
  ]

  NEW_BSD_CONFLICTS = [
    'MIT',
    'Simplified BSD',
    'zlib/libpng license',
    'Mozilla Public License 1.1',
    'Common Development and Distribution License 1.0',
    'AGPL-1.0+'
  ]

  GPL2_CONFLICTS = [
    'MIT',
    'Simplified BSD',
    'New BSD',
    'Apache 2.0',
    'zlib/libpng license',
    'AFL-3.0',
    'Mozilla Public License 1.1',
    'Mozilla Public License 2.0',
    'MPL-1.1+',
    'Common Development and Distribution License 1.0',
    'GNU Lesser General Public License version 2.1',
    'LGPL',
    'OSL-3.0',
    'AGPL-1.0+'
  ]

  GPL3_CONFLICTS = [
    'MIT',
    'Simplified BSD',
    'New BSD',
    'Apache 2.0',
    'zlib/libpng license',
    'AFL-3.0',
    'Mozilla Public License 1.1',
    'Mozilla Public License 2.0',
    'MPL-1.1+',
    'Common Development and Distribution License 1.0',
    'GNU Lesser General Public License version 2.1',
    'LGPL',
    'OSL-3.0',
    'GPLv2',
    'AGPL-1.0+'
  ]

  MPL2_CONFLICTS = [
    'MIT',
    'Simplified BSD',
    'New BSD',
    'Apache 2.0',
    'zlib/libpng license',
    'AFL-3.0',
    'Mozilla Public License 1.1',
    'MPL-1.1+',
    'Common Development and Distribution License 1.0',
    'LGPL',
    'OSL-3.0',
    'AGPL-1.0+'
  ]

  SIMPLIFIED_BSD_CONFLICTS = [
    'MIT',
    'zlib/libpng license',
    'Mozilla Public License 1.1',
    'Common Development and Distribution License 1.0',
    'AGPL-1.0+'
  ]

  CONFLICTS_MAP = {
    'MIT' => [
      'zlib/libpng license',
      'Mozilla Public License 1.1',
      'Common Development and Distribution License 1.0',
      'AGPL-1.0+',
      'MPL-1.1+'
    ],
    'Simplified BSD' => SIMPLIFIED_BSD_CONFLICTS,
    'BSD-2' => SIMPLIFIED_BSD_CONFLICTS,
    'BSD-2-Clause' => SIMPLIFIED_BSD_CONFLICTS,
    'New BSD' => NEW_BSD_CONFLICTS,
    'BSD-3-Clause' => NEW_BSD_CONFLICTS,
    'apache-2.0' => APACHE2_CONFLICTS,
    'Apache-2.0' => APACHE2_CONFLICTS,
    'Apache 2.0' => APACHE2_CONFLICTS,
    'zlib/libpng license' => [
      'MIT',
      'New BSD',
      'Simplified BSD',
      'Mozilla Public License 1.1',
      'Common Development and Distribution License 1.0',
      'AGPL-1.0+'
    ],
    'AFL-3.0' => [
      'MIT',
      'Simplified BSD',
      'New BSD',
      'Apache 2.0',
      'Mozilla Public License 1.1',
      'Mozilla Public License 2.0',
      'MPL-1.1+',
      'Common Development and Distribution License 1.0',
      'GNU Lesser General Public License version 2.1',
      'LGPL',
      'GPLv2',
      'GPLv3',
      'AGPL-3.0',
      'zlib/libpng license',
      'AGPL-1.0+'
    ],
    'Mozilla Public License 1.1' => [
      'MIT',
      'Simplified BSD',
      'New BSD',
      'Apache 2.0',
      'zlib/libpng license',
      'AFL-3.0',
      'MPL-1.1+',
      'LGPL',
      'OSL-3.0',
      'AGPL-1.0+'
    ],
    'MPL-2.0' => MPL2_CONFLICTS,
    'Mozilla Public License 2.0' => MPL2_CONFLICTS,
    'MPL-1.1+' => [
      'MIT',
      'Simplified BSD',
      'New BSD',
      'Apache 2.0',
      'zlib/libpng license',
      'AFL-3.0',
      'Mozilla Public License 1.1',
      'Mozilla Public License 2.0',
      'Common Development and Distribution License 1.0',
      'GNU Lesser General Public License version 2.1',
      'LGPL',
      'OSL-3.0',
      'GPLv2',
      'GPLv3',
      'AGPL-3.0',
      'AGPL-1.0+'
    ],
    'Common Development and Distribution License 1.0' => [
      'MIT',
      'Simplified BSD',
      'New BSD',
      'Apache 2.0',
      'zlib/libpng license',
      'AFL-3.0',
      'Mozilla Public License 1.1',
      'Mozilla Public License 2.0',
      'MPL-1.1+',
      'GNU Lesser General Public License version 2.1',
      'LGPL',
      'OSL-3.0',
      'GPLv2',
      'GPLv3',
      'AGPL-3.0',
      'AGPL-1.0+'
    ],
    'GNU Lesser General Public License version 2.1' => [
      'MIT',
      'Simplified BSD',
      'New BSD',
      'Apache 2.0',
      'zlib/libpng license',
      'AFL-3.0',
      'Mozilla Public License 1.1',
      'Mozilla Public License 2.0',
      'MPL-1.1+',
      'Common Development and Distribution License 1.0',
      'OSL-3.0',
      'AGPL-1.0+'
    ],
    'OSL-3.0' => [
      'MIT',
      'Simplified BSD',
      'New BSD',
      'Apache 2.0',
      'zlib/libpng license',
      'AFL-3.0',
      'Mozilla Public License 1.1',
      'Mozilla Public License 2.0',
      'MPL-1.1+',
      'Common Development and Distribution License 1.0',
      'GNU Lesser General Public License version 2.1',
      'LGPL',
      'GPLv2',
      'GPLv3',
      'AGPL-3.0',
      'AGPL-1.0+'
    ],
    'GPL-2.0' => GPL2_CONFLICTS,
    'GPLv2' => GPL2_CONFLICTS,
    'GPL-3.0' => GPL3_CONFLICTS,
    'GPLv3' => GPL3_CONFLICTS,
    'GPL-3.0-only' => GPL3_CONFLICTS,
    'AGPL-3.0' => [
      'MIT',
      'Simplified BSD',
      'New BSD',
      'Apache 2.0',
      'zlib/libpng license',
      'AFL-3.0',
      'Mozilla Public License 1.1',
      'Mozilla Public License 2.0',
      'MPL-1.1+',
      'Common Development and Distribution License 1.0',
      'GNU Lesser General Public License version 2.1',
      'LGPL',
      'OSL-3.0',
      'GPLv2',
      'GPLv3',
      'AGPL-1.0+'
    ],
    'AGPL-1.0+' => [
      'MIT',
      'Simplified BSD',
      'New BSD',
      'Apache 2.0',
      'zlib/libpng license',
      'AFL-3.0',
      'Mozilla Public License 1.1',
      'Mozilla Public License 2.0',
      'MPL-1.1+',
      'Common Development and Distribution License 1.0',
      'GNU Lesser General Public License version 2.1',
      'LGPL',
      'OSL-3.0',
      'GPLv2',
      'GPLv3'
    ]
  }.freeze
end