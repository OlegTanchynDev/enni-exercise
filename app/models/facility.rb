# frozen_string_literal: true

class Facility < ApplicationRecord
  belongs_to :venue
  has_one :operator, through: :venue
  has_many :booking_instances, dependent: :destroy

  validates :name, presence: true

  def upcoming_booking_instances(from: Time.current, days: 7)
    booking_instances
      .where(starts_at: from.beginning_of_day..(from + days.days).end_of_day)
      .order(:starts_at)
  end
end
