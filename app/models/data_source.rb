# frozen_string_literal: true

# DataSource model represents a data source associated with a user, containing
# necessary connection details and methods to manage its state.
class DataSource < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  has_many :tables, dependent: :destroy
  has_many :queries, dependent: :destroy

  before_save :encrypt_password
  before_save :unset_other_connected_sources, if: :connected

  after_destroy :activate_first_available_data_source_if_none_active

  belongs_to :user

  validates :name, presence: true
  validates :adapter, presence: true, inclusion: { in: %w[postgresql mysql sqlite] }
  validates :port, numericality: { only_integer: true }, allow_blank: true

  scope :active, -> { where(connected: true) }
  scope :inactive, -> { where(connected: false) }

  def encrypt_password
    self.password = encrypt(password) if password.present?
  end

  def decrypt_password
    decrypt(password)
  end

  private

  def encrypt(data)
    encryptor.encrypt_and_sign(data)
  end

  def decrypt(data)
    encryptor.decrypt_and_verify(data)
  end

  def encryptor
    key = Rails.application.credentials.secret_key_base[0..31]
    ActiveSupport::MessageEncryptor.new(key)
  end

  def unset_other_connected_sources
    user.data_sources.where.not(id:).update_all(connected: false)
  end

  def activate_first_available_data_source_if_none_active
    return unless user.data_sources.active.empty? && user.data_sources.inactive.any?

    user.data_sources.inactive.first.update(connected: true)
  end
end
