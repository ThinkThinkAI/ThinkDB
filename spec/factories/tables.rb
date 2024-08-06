# frozen_string_literal: true

FactoryBot.define do
  factory :table do
    sequence(:name) { |n| "name#{n}" }
    sequence(:slug) { |n| "slug#{n}" }
    association :data_source
  end
end
