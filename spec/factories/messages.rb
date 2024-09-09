# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    role { %w[user assistant].sample }
    content { Faker::Lorem.sentence }
    association :chat
  end
end
