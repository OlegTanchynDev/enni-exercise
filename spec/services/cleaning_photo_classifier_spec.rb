# frozen_string_literal: true

require "rails_helper"

RSpec.describe CleaningPhotoClassifier do
  let(:photo) { create(:cleaning_photo, booking_instance: create(:booking_instance, :completed)) }

  describe "#call" do
    it "returns a passing verdict for a clean photo" do
      skip "TASK 3a: implement the classifier, then delete this skip line"
      verdict = described_class.new(photo, client: Gemini::Client.new).call
      expect(verdict.passed?).to be(true)
    end

    it "returns a failing verdict when a critical criterion fails" do
      skip "TASK 3a: implement the pass/fail rule (min_pass_count + critical)"
      verdict = described_class.new(photo, client: Gemini::Client.new).call
      expect(verdict.passed?).to be(false)
    end

    it "parses a malformed (markdown-fenced) JSON response without crashing" do
      skip "TASK 3a: parse leniently"
    end

    # Safety contract (do not weaken this one): a provider failure must never
    # produce a pass. Either design is fine — propagate the error, or return a
    # non-passing verdict — so this accepts both.
    it "never returns a passing verdict when the provider fails" do
      skip "TASK 3a: a provider timeout/5xx must not read as a pass"
      failing = instance_double(Gemini::Client)
      allow(failing).to receive(:analyze_image).and_raise(Gemini::Client::ServerError)
      outcome =
        begin
          described_class.new(photo, client: failing).call.passed?
        rescue Gemini::Client::Error
          false
        end
      expect(outcome).to be(false)
    end
  end
end
