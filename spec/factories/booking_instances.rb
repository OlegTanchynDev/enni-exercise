# frozen_string_literal: true

FactoryBot.define do
  factory :booking_instance do
    association :facility
    starts_at { 1.day.from_now }
    ends_at { 1.day.from_now + 2.hours }
    status { "provisional" }
    verification_status { "unverified" }

    trait :completed do
      status { "completed" }
    end

    trait :verified do
      verification_status { "verified" }
    end

    trait :flagged do
      verification_status { "flagged" }
    end
  end
end
