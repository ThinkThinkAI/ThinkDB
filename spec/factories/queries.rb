# frozen_string_literal: true

FactoryBot.define do
  factory :query do
    sequence(:name) { |n| "Test Query #{n} #{Faker::Lorem.sentence}" }
    sql { 'SELECT * FROM users' }
    association :data_source
  end
end
