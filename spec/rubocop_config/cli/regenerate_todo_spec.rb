# frozen_string_literal: true

RSpec.describe RubocopConfig::CLI::RegenerateTodo do
  let(:regenerate_command) { described_class.new }

  before do
    # Mock file operations
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:read).and_return("mock file content")
    allow(regenerate_command).to receive(:puts)
    allow(regenerate_command).to receive(:exit)
    allow(regenerate_command).to receive(:system).and_return(true)
    allow(regenerate_command).to receive(:rubocop_yml_exists?).and_return(true)

    # Mock Digest for hash calculation
    allow(Digest::SHA256).to receive(:hexdigest).and_return("mock_hash")
  end

  describe "#call" do
    context "when .rubocop.yml exists" do
      before do
        allow(regenerate_command).to receive(:rubocop_yml_exists?).and_return(true)
      end

      context "when regeneration succeeds" do
        before do
          allow(regenerate_command).to receive(:system).and_return(true)
        end

        it "executes regeneration successfully" do
          regenerate_command.call

          expect(regenerate_command).to have_received(:system).with(/rubocop.*--regenerate-todo/)
          expect(regenerate_command).not_to have_received(:exit)
        end

        it "calculates file hash before and after" do
          expect(regenerate_command).to receive(:calculate_file_hash).with(".rubocop_todo.yml").twice

          regenerate_command.call
        end

        context "when TODO file is unchanged" do
          before do
            allow(regenerate_command).to receive(:calculate_file_hash)
              .and_return("same_hash", "same_hash")
          end

          it "reports no changes" do
            expect(regenerate_command).to receive(:puts).with(/TODO file unchanged/)

            regenerate_command.call
          end
        end

        context "when TODO file is changed" do
          before do
            allow(regenerate_command).to receive(:calculate_file_hash)
              .and_return("old_hash", "new_hash")
          end

          it "reports changes" do
            expect(regenerate_command).to receive(:puts).with(/TODO file was updated/)

            regenerate_command.call
          end
        end
      end

      context "when regeneration fails" do
        before do
          allow(regenerate_command).to receive(:system).and_return(false)
        end

        it "exits with error" do
          regenerate_command.call

          expect(regenerate_command).to have_received(:exit).with(1)
        end
      end
    end

    context "when .rubocop.yml does not exist" do
      before do
        allow(regenerate_command).to receive(:rubocop_yml_exists?).and_return(false)
      end

      it "exits with error message" do
        regenerate_command.call

        expect(regenerate_command).to have_received(:exit).with(1)
      end
    end
  end

  describe "#build_command" do
    before do
      allow(regenerate_command).to receive(:rubocop_command).and_return("bundle exec rubocop")
    end

    it "builds correct command with all required options" do
      command = regenerate_command.send(:build_command)

      expect(command).to eq("bundle exec rubocop --regenerate-todo --no-exclude-limit --no-offense-counts --no-auto-gen-timestamp")
    end
  end

  describe "#calculate_file_hash" do
    context "when file exists" do
      before do
        allow(File).to receive(:exist?).with("test_file.yml").and_return(true)
        allow(File).to receive(:read).with("test_file.yml").and_return("file content")
        allow(Digest::SHA256).to receive(:hexdigest).with("file content").and_return("calculated_hash")
      end

      it "returns SHA256 hash of file content" do
        hash = regenerate_command.send(:calculate_file_hash, "test_file.yml")

        expect(hash).to eq("calculated_hash")
        expect(Digest::SHA256).to have_received(:hexdigest).with("file content")
      end
    end

    context "when file does not exist" do
      before do
        allow(File).to receive(:exist?).with("nonexistent_file.yml").and_return(false)
      end

      it "returns nil" do
        hash = regenerate_command.send(:calculate_file_hash, "nonexistent_file.yml")

        expect(hash).to be_nil
        expect(File).not_to have_received(:read)
      end
    end
  end
end