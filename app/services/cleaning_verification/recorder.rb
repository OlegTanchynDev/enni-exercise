# frozen_string_literal: true

module CleaningVerification
  # TASK 1a. Drives the verification_status transition from a classifier verdict
  # (verified on pass, flagged on fail). House style: keyword-arg init, attr_reader,
  # a plain instance method, not a `.call` wrapper. Mind the guards — an already
  # verified booking, one that was never completed, a re-classified photo.
  # Spec: spec/services/cleaning_verification/recorder_spec.rb.
  class Recorder
    def initialize(booking_instance:, verdict:)
      @booking_instance = booking_instance
      @verdict = verdict
    end

    attr_reader :booking_instance, :verdict

    def record
      return unless booking_instance.completed?
      return unless booking_instance.pending?

      if verdict.passed?
        booking_instance.pass_verification!
      else
        booking_instance.flag_verification!
      end
    end
  end
end
