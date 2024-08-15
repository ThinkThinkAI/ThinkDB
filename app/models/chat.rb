class Chat < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :data_source
  has_many :messages, dependent: :destroy
end
