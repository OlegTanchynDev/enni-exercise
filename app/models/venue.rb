# frozen_string_literal: true

class Venue < ApplicationRecord
  belongs_to :operator
  has_many :facilities, dependent: :destroy
  has_many :booking_instances, through: :facilities

  validates :name, presence: true
end
