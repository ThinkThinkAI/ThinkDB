# frozen_string_literal: true

FactoryBot.define do
  factory :data_source do
    adapter { 'postgresql' }
    host { 'localhost' }
    port { 5432 }
    database { 'your_database_name' }
    username { 'your_username' }
    password { 'your_password' }
    user
    connected { true }
    name { 'Example Data Source' }
  end
end
