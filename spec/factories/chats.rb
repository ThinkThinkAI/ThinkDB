FactoryBot.define do
  factory :chat do
    name { 'MyString' }
    association :data_source
    sequence(:slug) { |n| "chat-#{n}" }

    after(:create) do |chat|
      create_list(:message, 3, chat:)
    end
  end
end
