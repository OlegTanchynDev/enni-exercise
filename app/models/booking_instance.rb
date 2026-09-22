# frozen_string_literal: true

class BookingInstance < ApplicationRecord
  include AASM

  audited

  belongs_to :facility
  belongs_to :customer, class_name: "User", optional: true
  has_many :cleaning_photos, dependent: :destroy

  has_one :venue, through: :facility
  has_one :operator, through: :venue

  validates :starts_at, :ends_at, presence: true
  validate :ends_after_starts

  # ── Booking lifecycle — the PATTERN to mirror for verification_status ───────
  # AASM auto-generates state scopes (BookingInstance.completed, .confirmed, …)
  # and predicate methods (#completed?). Note the guarded transitions. This
  # machine is given the name :status because a model with two AASM machines
  # must name both (see TASK 1a).
  aasm(:status, column: :status) do
    state :provisional, initial: true
    state :confirmed
    state :completed
    state :cancelled

    event :confirm do
      transitions from: :provisional, to: :confirmed
    end

    event :complete do
      transitions from: :confirmed, to: :completed
    end

    event :cancel do
      transitions from: %i[provisional confirmed], to: :cancelled
    end
  end

  # TASK 1a. Add a second, named AASM machine on verification_status that mirrors
  # the one above: unverified (initial) -> pending -> verified | flagged. Both
  # machines must be named (hence aasm(:status, ...) above). It's driven by
  # CleaningVerification::Recorder; this model is already audited, so keep the
  # transitions auditable.

  def latest_cleaning_photo
    cleaning_photos.order(created_at: :desc).first
  end

  private

  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "must be after the start time") if ends_at <= starts_at
  end
end
