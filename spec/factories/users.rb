# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    ai_url { 'http://example.com' }
    ai_model { 'example_model' }
    ai_api_key { 'example_key' }
  end
end
