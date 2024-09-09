# frozen_string_literal: true

FactoryBot.define do
  factory :q_chat do
    name { 'MyString' }
    association :data_source
    sequence(:slug) { |n| "chat-#{n}" }

    after(:create) do |chat|
      create_list(:message, 3, chat:)
    end
  end
end
