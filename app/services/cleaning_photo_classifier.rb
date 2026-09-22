# frozen_string_literal: true

# TASK 3a (see the README). Turn a photo into a pass/fail verdict: load the
# criteria from config/cleaning_criteria.yml, call the Gemini stub, parse its
# (sometimes fenced) JSON, and apply the rule. A provider failure must never read
# as a pass. The worker expects the verdict to answer #passed? and #to_h.
# Contract: spec/services/cleaning_photo_classifier_spec.rb.
class CleaningPhotoClassifier
  CRITERIA_PATH = Rails.root.join("config/cleaning_criteria.yml")

  def initialize(cleaning_photo, client: Gemini::Client.new)
    @cleaning_photo = cleaning_photo
    @client = client
  end

  def call
    raise NotImplementedError, "TASK 3a: implement the cleaning photo classifier"
  end
end
