# frozen_string_literal: true

# A tenant. Owns venues, facilities, and the bookings within them. The whole
# verification feature is scoped so an operator only ever sees its own data.
class Operator < ApplicationRecord
  has_many :operator_users, dependent: :destroy
  has_many :venues, dependent: :destroy
  has_many :facilities, through: :venues
  has_many :booking_instances, through: :facilities

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
end
