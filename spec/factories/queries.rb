# frozen_string_literal: true

FactoryBot.define do
  factory :query do
    sequence(:name) { |n| "Test Query #{n}" }
    sql { 'SELECT * FROM users' }
    data_source
  end
end
