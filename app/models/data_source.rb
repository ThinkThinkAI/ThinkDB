class DataSource < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :tables, dependent: :destroy
  has_many :queries, dependent: :destroy
  has_many :chats, dependent: :destroy
  has_many :qchats, dependent: :destroy, class_name: 'QChat'

  before_save :encrypt_password, if: :password_changed?
  before_save :unset_other_connected_sources, if: :connected

  after_save :build_tables_if_connected

  after_destroy :activate_first_available_data_source_if_none_active

  belongs_to :user

  validates :name, presence: true
  validates :adapter, presence: true, inclusion: { in: %w[postgresql mysql sqlite test] }
  validates :port, numericality: { only_integer: true }, allow_blank: true

  scope :active, -> { where(connected: true) }
  scope :inactive, -> { where(connected: false) }

  def decrypt_password
    decrypt(password) if password.present?
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    nil
  end

  private

  def encrypt_password
    self.password = encrypt(password) if password.present?
  end

  def encrypt(data)
    encryptor.encrypt_and_sign(data)
  end

  def decrypt(data)
    encryptor.decrypt_and_verify(data)
  end

  def encryptor
    secret_key_base = ENV['SECRET_KEY_BASE'] || '63713599ea6fa5f3a63f41cbe71f63ff284535245c18ae375c0b8d735ca8e601'
    # Ensure key is 32 bytes long for AES-256
    key = secret_key_base[0..31]
    ActiveSupport::MessageEncryptor.new(key, cipher: 'aes-256-gcm')
  end

  def unset_other_connected_sources
    user.data_sources.where.not(id:).update_all(connected: false)
  end

  def activate_first_available_data_source_if_none_active
    return unless user.data_sources.active.empty? && user.data_sources.inactive.any?

    user.data_sources.inactive.first.update(connected: true)
  end

  def build_tables_if_connected
    return unless saved_change_to_connected? && connected?

    database_service = DatabaseService.build(self)
    database_service&.build_tables
  end

  def password_changed?
    saved_change_to_password?
  end
end
