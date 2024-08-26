# frozen_string_literal: true

# The Chat model represents a conversation session within the application.
# It includes functionality for generating URL-friendly slugs based on the chat name using the FriendlyId gem.
# A Chat belongs to a DataSource and can have many Messages. It requires a name to be present.
class Chat < ApplicationRecord
  self.inheritance_column = :type

  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :data_source
  has_many :messages, dependent: :destroy

  validates :name, presence: true

  scope :excluding_qchats, -> { where.not(type: 'QChat') }

  def qchat?
    is_a?(QChat)
  end
end
