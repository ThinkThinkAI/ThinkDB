# frozen_string_literal: true

FactoryBot.define do
  factory :data_source do
    adapter { 'postgresql' }
    host { 'MyString' }
    port { 1 }
    database { 'MyString' }
    username { 'MyString' }
    password { 'MyString' }
    user { nil }
  end
end
