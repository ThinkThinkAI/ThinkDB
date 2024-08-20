FactoryBot.define do
  factory :chat do
    name { 'MyString' }
    association :data_source
    slug { 'MyString' }

    after(:create) do |chat|
      create_list(:message, 3, chat:)
    end
  end
end
