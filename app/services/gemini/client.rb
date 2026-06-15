# frozen_string_literal: true

module Gemini
  # Deterministic, offline stand-in for the real Gemini client — no network, no
  # API key, no cost, no flakiness. It mirrors the SHAPE of the real
  # GeminiProvider#analyze_image: give it image bytes + a prompt, get back the
  # model's response TEXT (a raw string), which your classifier must parse.
  #
  # Behaviour is driven by a `marker` so seeds and specs are reproducible:
  #   - (default)            → clean PASS  (all criteria score high)
  #   - marker ~ "dirty"     → FAIL        (criteria score low)
  #   - marker ~ "malformed" → valid JSON wrapped in ```json fences + trailing junk
  #   - marker ~ "timeout"   → raises Gemini::Client::TimeoutError
  #   - marker ~ "error"     → raises Gemini::Client::ServerError (simulated 5xx)
  #
  # Note it returns a STRING, not a Hash — parsing (including the malformed case)
  # is the classifier's job, exactly like the real provider.
  class Client
    class Error < StandardError; end
    class TimeoutError < Error; end
    class ServerError < Error; end

    MODEL = "gemini-2.5-flash-lite-stub"

    def initialize(api_key: nil)
      @api_key = api_key
    end

    def analyze_image(image_bytes:, prompt:, marker: nil)
      _ = [image_bytes, prompt] # accepted for interface parity with the real provider
      hint = marker.to_s.downcase

      raise TimeoutError, "stub: simulated upstream timeout" if hint.include?("timeout")
      raise ServerError, "stub: simulated 502 from provider" if hint.include?("error")

      payload = hint.include?("dirty") ? fail_payload : pass_payload
      hint.include?("malformed") ? malformed(payload) : payload.to_json
    end

    private

    def pass_payload
      { criteria: {
        floor_clean: { score: 92, observations: ["floor swept and mopped"] },
        surfaces_wiped: { score: 88, observations: ["surfaces clear and wiped"] },
        waste_removed: { score: 95, observations: ["bins emptied"] }
      } }
    end

    def fail_payload
      { criteria: {
        floor_clean: { score: 40, observations: ["visible debris near the entrance"] },
        surfaces_wiped: { score: 55, observations: ["dust on the window sills"] },
        waste_removed: { score: 30, observations: ["bin still full"] }
      } }
    end

    # The real model occasionally wraps JSON in markdown fences with trailing
    # characters. Your parser must cope, like the real provider's lenient parse.
    def malformed(payload)
      "```json\n#{payload.to_json}\n```  <<end>>"
    end
  end
end
