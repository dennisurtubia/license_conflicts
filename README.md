# license_conflicts

**license_conflicts** detects software license incompatibilities between a project and its dependencies. It identifies the project's license, scans all dependency licenses using [LicenseFinder](https://github.com/pivotal/LicenseFinder), and reports any conflicts — making it easy to integrate license compliance checks into your CI/CD pipeline.

---

## Table of Contents

- [How It Works](#how-it-works)
- [Supported Languages](#supported-languages)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Output](#output)
- [Report Formats](#report-formats)
- [Supported Licenses](#supported-licenses)
- [Exit Codes](#exit-codes)
- [Contributing](#contributing)
- [License](#license)

---

## How It Works

1. **Detects the project license** from its metadata file (`package.json`, `gemspec`, `pom.xml`, etc.)
2. **Scans all dependencies** using LicenseFinder
3. **Normalizes license names** — SPDX identifiers, common aliases, and variant spellings are all mapped to canonical names
4. **Checks for conflicts** using a built-in compatibility matrix
5. **Reports results** to stdout and exits with an appropriate code

---

## Supported Languages

| Language   | Package Manager | Metadata File                 |
|------------|-----------------|-------------------------------|
| JavaScript | npm             | `package.json`                |
| JavaScript | Bower           | `bower.json`                  |
| Ruby       | Bundler         | `*.gemspec`                   |
| Python     | pip / Poetry    | `setup.cfg`, `pyproject.toml` |
| Go         | Go modules      | `go.mod`                      |
| Go         | Godep           | `Godeps/Godeps.json`          |
| Java       | Maven           | `pom.xml`                     |

---

## Requirements

- Ruby >= 2.6.0
- The package manager for your project type must be installed (e.g. `npm`, `bundler`, `mvn`)

---

## Installation

```bash
gem install license_conflicts
```

---

## Usage

Run inside the root directory of the project you want to analyze:

```bash
license_conflicts
```

To generate a detailed dependency report alongside the conflict check:

```bash
license_conflicts check --format markdown
```

To display the installed version:

```bash
license_conflicts version
```

### Options

| Flag              | Alias        | Description                                                              |
|-------------------|--------------|--------------------------------------------------------------------------|
| `--format FORMAT` | `-f FORMAT`  | Report format: `text`, `html`, `markdown`, `csv`, `xml`, `json`, `junit` |

---

## Output

Results are printed to **stdout** as a single comma-separated line:

```
{dependency_count}, {project_license}, {conflicting_licenses}, {report}
```

| Field                 | Description                                                                      |
|-----------------------|----------------------------------------------------------------------------------|
| `dependency_count`    | Number of scanned dependencies                                                   |
| `project_license`     | Detected license of the analyzed project                                         |
| `conflicting_licenses`| Semicolon-separated list of incompatible licenses found (empty if none)          |
| `report`              | Full dependency report (only present when `--format` is specified)               |

### Examples

No conflicts found:

```
42, MIT, ,
```

Conflicts detected:

```
42, MIT, GPLv2;AGPL 3,
```

With a Markdown report:

```
42, MIT, GPLv2, ## Dependencies ...
```

Diagnostic messages and errors are written to **stderr** and do not affect the stdout output format.

---

## Report Formats

When `--format` is provided, a full dependency report is appended to the output. Available formats:

| Format     | Flag value |
|------------|------------|
| Plain text | `text`     |
| HTML       | `html`     |
| Markdown   | `markdown` |
| CSV        | `csv`      |
| XML        | `xml`      |
| JSON       | `json`     |
| JUnit XML  | `junit`    |

---

## Supported Licenses

The following licenses are recognized in the conflict matrix:

`MIT` · `Apache 2.0` · `New BSD` · `Simplified BSD` · `GPLv2` · `GPLv3` · `LGPL 2.1` · `LGPL 3.0` · `MPL 1.1` · `MPL 2.0` · `CDDL 1.0` · `AFL 3.0` · `OSL 3.0` · `AGPL 3` · `AGPL 1.0` · `EPL 1.0` · `EPL 2.0` · `ISC` · `Zlib` · `Unlicense`

The normalizer recognizes SPDX identifiers and common aliases for all of the above (e.g. `Apache-2.0`, `GPL-3.0-only`, `BSD-3-Clause`). Unrecognized license names are passed through as-is and checked against the matrix.

---

## Exit Codes

| Code | Meaning                                                                         |
|------|---------------------------------------------------------------------------------|
| `0`  | No license conflicts found                                                      |
| `1`  | One or more license conflicts detected                                          |
| `2`  | Error during execution (license not found, unsupported license, invalid option) |

---

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Write tests for your changes
4. Run the test suite (`bundle exec rspec`)
5. Open a Pull Request

### Running Tests

```bash
bundle install
bundle exec rspec
```

---

## License

This project is released under the [MIT License](LICENSE).
