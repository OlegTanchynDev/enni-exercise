# frozen_string_literal: true

FactoryBot.define do
  factory :operator do
    sequence(:name) { |n| "Operator #{n}" }
    sequence(:slug) { |n| "operator-#{n}" }
  end
end
