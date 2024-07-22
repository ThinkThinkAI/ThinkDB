FactoryBot.define do
  factory :query do
    query { "MyString" }
    data_source { nil }
  end
end
