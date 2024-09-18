# frozen_string_literal: true

FactoryBot.define do
  factory :data_source do
    adapter { 'test' }
    host { 'localhost' }
    port { 5432 }
    database { 'your_database_name' }
    username { 'your_username' }
    password { 'your_password' }
    user
    connected { true }
    sequence(:name) { |n| "name#{n}" }
    sequence(:slug) { |n| "slug#{n}" }
  end
end
