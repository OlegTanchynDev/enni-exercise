# frozen_string_literal: true

class CleaningPhoto < ApplicationRecord
  include ImageUploader::Attachment(:image)

  belongs_to :booking_instance
  belongs_to :uploaded_by, class_name: "User", optional: true
  has_many :image_classifications, dependent: :destroy

  # Uploading a cleaning photo kicks off async classification (mirrors the real
  # Enni classify_photo_worker flow). The worker, classifier, and recorder do
  # the actual work — see TASK 3a / 1a.
  after_create_commit :enqueue_classification

  def latest_classification
    image_classifications.order(created_at: :desc).first
  end

  private

  def enqueue_classification
    ClassifyCleaningPhotoWorker.perform_async(id)
  end
end
