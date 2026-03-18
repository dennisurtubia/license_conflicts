# frozen_string_literal: true

require 'license_conflicts/cli'

RSpec.describe LicenseConflicts::CLI do
  subject(:cli) { described_class.new }

  let(:finder) { instance_double(LicenseConflicts::Finder) }
  let(:gpl_dep) { double("dependency", name: "gpl-gem", licenses: [double(name: "GPLv2")]) }

  before do
    allow(LicenseConflicts::Finder).to receive(:new).and_return(finder)
    allow(finder).to receive(:dependencies_count).and_return(5)
    allow(finder).to receive(:project_license).and_return("MIT")
    allow($stderr).to receive(:print)
    allow($stderr).to receive(:puts)
  end

  # Captures what is printed to $stdout during the block.
  # Necessary because cli commands call exit(), which interrupts the rspec
  # `output` matcher before it can evaluate the assertion.
  def capture_stdout
    chunks = []
    allow($stdout).to receive(:print) { |msg| chunks << msg }
    allow($stdout).to receive(:puts)  { |msg| chunks << "#{msg}\n" }
    yield
    chunks.join
  rescue SystemExit
    chunks.join
  end

  describe "#version" do
    it "prints the current version" do
      expect { cli.version }.to output("#{LicenseConflicts::VERSION}\n").to_stdout
    end
  end

  describe "#check" do
    context "with no conflicts" do
      before { allow(finder).to receive(:find_conflicts).and_return([]) }

      it "prints dependency count, project license and empty conflicts to stdout" do
        output = capture_stdout { cli.check }
        expect(output).to eq("5, MIT, , ")
      end

      it "exits with code 0" do
        expect { cli.check }.to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
      end
    end

    context "with conflicts found" do
      before { allow(finder).to receive(:find_conflicts).and_return([gpl_dep]) }

      it "prints the conflicting license names to stdout" do
        output = capture_stdout { cli.check }
        expect(output).to eq("5, MIT, GPLv2, ")
      end

      it "exits with code 1" do
        expect { cli.check }.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
      end

      it "prints multiple conflicting licenses separated by semicolons" do
        agpl_dep = double("dependency", name: "agpl-gem", licenses: [double(name: "AGPL 3")])
        allow(finder).to receive(:find_conflicts).and_return([gpl_dep, agpl_dep])

        output = capture_stdout { cli.check }
        expect(output).to eq("5, MIT, GPLv2;AGPL 3, ")
      end
    end

    context "with a valid --format option" do
      before do
        allow(finder).to receive(:find_conflicts).and_return([gpl_dep])
        cli.options = { format: "markdown" }
      end

      it "delegates to Report with the given format" do
        report = instance_double(LicenseConflicts::Report)
        expect(LicenseConflicts::Report).to receive(:new).with([gpl_dep], "markdown").and_return(report)
        expect(report).to receive(:report)

        expect { cli.check }.to raise_error(SystemExit)
      end
    end

    context "with an invalid --format option" do
      before { cli.options = { format: "pdf" } }

      it "prints an error to stderr" do
        expect($stderr).to receive(:puts).with(/Invalid format 'pdf'/)
        expect { cli.check }.to raise_error(SystemExit)
      end

      it "exits with code 2" do
        allow($stderr).to receive(:puts)
        expect { cli.check }.to raise_error(SystemExit) { |e| expect(e.status).to eq(2) }
      end
    end

    context "when Finder raises an error" do
      before do
        allow(finder).to receive(:find_conflicts).and_raise(StandardError, "license_not_found")
      end

      it "prints the error message to stderr" do
        expect($stderr).to receive(:puts).with("license_not_found")
        expect { cli.check }.to raise_error(SystemExit)
      end

      it "exits with code 2" do
        expect { cli.check }.to raise_error(SystemExit) { |e| expect(e.status).to eq(2) }
      end

      it "prints partial output to stdout even on error" do
        output = capture_stdout { cli.check }
        expect(output).to eq("5, MIT, , ")
      end
    end
  end
end
