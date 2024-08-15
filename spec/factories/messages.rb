FactoryBot.define do
  factory :message do
    role { "MyString" }
    content { "MyText" }
    chat { nil }
  end
end
