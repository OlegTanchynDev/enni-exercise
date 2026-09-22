# frozen_string_literal: true

FactoryBot.define do
  factory :image_classification do
    association :cleaning_photo
    status { "pending" }
    result { {} }
  end
end
