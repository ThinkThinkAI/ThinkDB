FactoryBot.define do
  factory :table do
    name { 'MyString' }
    association :data_source
  end
end
