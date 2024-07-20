FactoryBot.define do
  factory :table do
    name { 'MyString' }
    schema { 'public' }
    data_source { nil }
  end
end
