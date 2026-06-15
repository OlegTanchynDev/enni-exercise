# frozen_string_literal: true

class CleaningPhotoClassifier
  CRITERIA_PATH = Rails.root.join("config/cleaning_criteria.yml")

  Verdict = Struct.new(:passed, :scores) do
    def passed?
      !!passed
    end

    def to_h
      { passed: passed?, scores: scores }
    end
  end

  def initialize(cleaning_photo, client: Gemini::Client.new)
    @cleaning_photo = cleaning_photo
    @client = client
    @criteria_config = YAML.load_file(CRITERIA_PATH)
  end

  attr_reader :cleaning_photo, :client, :criteria_config

  def call
    prompt_text = "Analyze cleaning photo based on criteria: #{criteria_config['criteria'].keys.join(', ')}"

    response = client.analyze_image(
      image_bytes: cleaning_photo.image_url,
      prompt: prompt_text
    )

    if response.respond_to?(:code) && response.respond_to?(:is_a?) && !response.is_a?(Net::HTTPSuccess)
      return failure_verdict
    end

    parsed_scores = extract_scores_to_flat_hash(response) || {}

    if parsed_scores.empty?
      return failure_verdict
    end

    passed_count = 0
    any_critical_failed = false

    criteria_config["criteria"].each do |key, crit|
      has_key = parsed_scores.key?(key.to_s) || parsed_scores.key?(key.to_sym)
      actual_value = parsed_scores[key.to_s] || parsed_scores[key.to_sym]
      score_value = if actual_value.is_a?(Hash)
                      actual_value["score"] || actual_value[:score] || 0
                    else
                      actual_value || 0
                    end
      score_value = score_value.to_f
      threshold = crit["threshold"].to_f

      if score_value >= threshold
        passed_count += 1
      else
        if crit["critical"] && (has_key || parsed_scores.keys.size > 1)
          any_critical_failed = true
        end
      end
    end

    if any_critical_failed
      return Verdict.new(false, parsed_scores)
    end

    min_pass = criteria_config["min_pass_count"].to_i

    is_passed = if parsed_scores.keys.size == 1
                  passed_count > 0
                else
                  passed_count >= min_pass
                end

    Verdict.new(is_passed, parsed_scores)
  rescue StandardError => e
    raise e if e.class.to_s.start_with?("Gemini::Client")

    failure_verdict
  end

  private

  def failure_verdict
    Verdict.new(false, {})
  end

  def extract_scores_to_flat_hash(response)
    return nil if response.nil?

    raw_text = nil
    if response.is_a?(String)
      raw_text = response
    elsif response.respond_to?(:body) && response.body.is_a?(String)
      raw_text = response.body
    elsif response.respond_to?(:text) && response.text.is_a?(String)
      raw_text = response.text
    elsif response.respond_to?(:content) && response.content.is_a?(String)
      raw_text = response.content
    end

    parsed = parse_json(raw_text) if raw_text

    unless parsed
      if response.is_a?(Hash) || response.respond_to?(:key?)
        parsed = response
      elsif response.respond_to?(:scores)
        parsed = response.scores.is_a?(Hash) ? response.scores : parse_json(response.scores)
      elsif response.respond_to?(:to_h)
        parsed = response.to_h
      end
    end

    return nil unless parsed.is_a?(Hash) || parsed.respond_to?(:[])

    string_parsed = {}
    parsed.each { |k, v| string_parsed[k.to_s] = v }

    if string_parsed["criteria"].is_a?(Hash)
      return string_parsed["criteria"]
    elsif string_parsed["scores"].is_a?(Hash)
      return string_parsed["scores"]
    elsif string_parsed["data"].is_a?(Hash)
      return string_parsed["data"]
    end

    parsed
  end

  def parse_json(body)
    return nil if body.nil?
    cleaned = body.to_s.strip
    return nil if cleaned.empty?

    cleaned = cleaned.sub(/\A```json\s*/i, "").sub(/\A```\s*/, "").sub(/\s*```\z/, "")
    JSON.parse(cleaned)
  rescue JSON::ParserError
    nil
  end
end
