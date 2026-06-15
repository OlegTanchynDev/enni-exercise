# frozen_string_literal: true

require "rails_helper"

RSpec.describe CleaningPhotoClassifier do
  let(:photo) { create(:cleaning_photo, booking_instance: create(:booking_instance, :completed)) }
  let(:client) { instance_double(Gemini::Client) }

  before do
    allow(Gemini::Client).to receive(:new).and_return(client)
  end

  describe "#call" do
    it "returns a passing verdict for a clean photo" do
      good_response = {
        "floor_clean" => { "score" => 95 },
        "surfaces_wiped" => { "score" => 90 },
        "waste_removed" => { "score" => 98 }
      }
      allow(client).to receive(:analyze_image).and_return(good_response.to_json)

      verdict = described_class.new(photo).call
      expect(verdict.passed?).to be(true)
    end

    it "returns a failing verdict when a critical criterion fails" do
      bad_response = {
        "floor_clean" => { "score" => 35 },
        "surfaces_wiped" => { "score" => 90 },
        "waste_removed" => { "score" => 98 }
      }
      allow(client).to receive(:analyze_image).and_return(bad_response.to_json)

      verdict = described_class.new(photo).call
      expect(verdict.passed?).to be(false)
    end

    it "parses a malformed (markdown-fenced) JSON response without crashing" do
      malformed_json_response = "```json\n{ \"floor_clean\": { \"score\": 95 } }\n```"
      allow(client).to receive(:analyze_image).and_return(malformed_json_response)

      verdict = described_class.new(photo).call
      expect(verdict.passed?).to eq(true)
    end

    it "never returns a passing verdict when the provider fails" do
      allow(client).to receive(:analyze_image).and_raise(Gemini::Client::ServerError)

      outcome =
        begin
          described_class.new(photo).call.passed?
        rescue Gemini::Client::Error
          false
        end
      expect(outcome).to be(false)
    end
  end
end
