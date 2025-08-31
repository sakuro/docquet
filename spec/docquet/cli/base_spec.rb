# frozen_string_literal: true

RSpec.describe Docquet::CLI::Base do
  let(:base_instance) { Docquet::CLI::Base.new }

  before do
    # Mock system calls to prevent actual execution
    allow(base_instance).to receive(:system).and_return(true)
  end

  describe "#rubocop_yml_exists?" do
    context "when .rubocop.yml exists" do
      before do
        allow(File).to receive(:exist?).with(".rubocop.yml").and_return(true)
      end

      it "returns true" do
        expect(base_instance.send(:rubocop_yml_exists?)).to be true
      end
    end

    context "when .rubocop.yml does not exist" do
      before do
        allow(File).to receive(:exist?).with(".rubocop.yml").and_return(false)
      end

      it "returns false" do
        expect(base_instance.send(:rubocop_yml_exists?)).to be false
      end
    end
  end

  describe "#rubocop_command" do
    context "when bundle is available" do
      before do
        allow(base_instance).to receive(:system).with("which bundle > /dev/null 2>&1").and_return(true)
      end

      it "returns bundle exec rubocop" do
        expect(base_instance.send(:rubocop_command)).to eq("bundle exec rubocop")
      end
    end

    context "when bundle is not available" do
      before do
        allow(base_instance).to receive(:system).with("which bundle > /dev/null 2>&1").and_return(false)
      end

      it "returns rubocop" do
        expect(base_instance.send(:rubocop_command)).to eq("rubocop")
      end
    end
  end

  describe "#bundle_exec_available?" do
    context "when bundle command exists" do
      before do
        allow(base_instance).to receive(:system).with("which bundle > /dev/null 2>&1").and_return(true)
      end

      it "returns true" do
        expect(base_instance.send(:bundle_exec_available?)).to be true
      end
    end

    context "when bundle command does not exist" do
      before do
        allow(base_instance).to receive(:system).with("which bundle > /dev/null 2>&1").and_return(false)
      end

      it "returns false" do
        expect(base_instance.send(:bundle_exec_available?)).to be false
      end
    end
  end
end
