# frozen_string_literal: true

FactoryBot.define do
  factory :cleaning_photo do
    association :booking_instance
    # No image attached by default; attach one explicitly where a spec needs it.
  end
end
