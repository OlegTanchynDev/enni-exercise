# frozen_string_literal: true

# The outcome of running a cleaning photo through the AI classifier. The
# candidate's CleaningPhotoClassifier writes `result` (per-criterion scores) and
# `passed`; the worker drives the status transitions.
class ImageClassification < ApplicationRecord
  include AASM

  belongs_to :cleaning_photo

  aasm column: :status do
    state :pending, initial: true
    state :processing
    state :completed
    state :failed

    event :start do
      transitions from: :pending, to: :processing
    end

    event :succeed do
      transitions from: :processing, to: :completed
    end

    event :flag_failed do
      transitions from: %i[pending processing], to: :failed
    end
  end
end
