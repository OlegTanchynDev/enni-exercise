# frozen_string_literal: true

# Provided. Orchestrates async classification (mirrors the real Enni
# classify_photo_worker): create the ImageClassification, run the candidate's
# classifier, persist the result, and hand the verdict to the Recorder. You fill
# in the classifier (TASK 3a) and the recorder (TASK 1a); this wiring is given so
# the async flow + live UI badge work end-to-end once those are done.
#
# The contract this assumes (design your classifier's Result to match):
#   verdict.passed?  -> Boolean
#   verdict.to_h     -> Hash (stored on the classification's `result`)
class ClassifyCleaningPhotoWorker
  include Sidekiq::Job

  sidekiq_options retry: 3

  def perform(cleaning_photo_id)
    photo = CleaningPhoto.find(cleaning_photo_id)
    classification = photo.image_classifications.create!
    classification.start!

    verdict = CleaningPhotoClassifier.new(photo).call

    classification.update!(result: verdict.to_h, passed: verdict.passed?, classified_at: Time.current)
    classification.succeed!

    CleaningVerification::Recorder.new(
      booking_instance: photo.booking_instance,
      verdict: verdict
    ).record
  rescue Gemini::Client::Error => e
    # Transient provider failure: record it and let Sidekiq retry. The booking
    # is NOT marked verified — a missing result must never read as a pass.
    classification&.update(error_message: e.message)
    classification&.flag_failed!
    raise
  end
end
