# frozen_string_literal: true

# User model represents a user in the system. Each user can have multiple
# associated data sources and possibly one currently connected data source.
class User < ApplicationRecord
  has_many :data_sources, dependent: :destroy
  has_one :connected_data_source, -> { where(connected: true) }, class_name: 'DataSource'
  validates :darkmode, inclusion: { in: [true, false] }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:github]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.image = auth.info.image
    end
  end

  def settings_incomplete?
    ai_url.blank? || ai_model.blank? || ai_api_key.blank?
  end
end
