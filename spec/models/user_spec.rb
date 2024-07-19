# frozen_string_literal: true

# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Associations' do
    it { should have_many(:data_sources).dependent(:destroy) }
    it { should have_one(:connected_data_source).class_name('DataSource') }
  end

  describe 'Devise modules' do
    # Test for Devise database_authenticatable
    it 'has a secure password' do
      user = User.new(password: 'password123', password_confirmation: 'password123')
      expect(user.valid_password?('password123')).to be true
    end

    # Test for Devise recoverable
    it 'responds to reset_password_token' do
      user = create(:user)
      expect(user).to respond_to(:reset_password_token)
    end

    # Test for Devise registerable
    it 'responds to email' do
      user = create(:user)
      expect(user).to respond_to(:email)
    end

    # Test for Devise rememberable
    it 'responds to remember_me' do
      user = create(:user)
      expect(user).to respond_to(:remember_me)
    end

    # Test for Devise validatable
    it 'validates email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    # Test for Devise omniauthable
    it 'responds to provider and uid' do
      user = create(:user)
      expect(user).to respond_to(:provider)
      expect(user).to respond_to(:uid)
    end
  end

  describe '.from_omniauth' do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: 'github',
        uid: '123545',
        info: {
          email: 'user@example.com',
          name: 'John Doe',
          image: 'http://example.com/image.png'
        }
      )
    end

    context 'when user does not exist' do
      it 'creates a new user from the omniauth hash' do
        expect do
          User.from_omniauth(auth)
        end.to change { User.count }.by(1)

        user = User.last
        expect(user.provider).to eq(auth.provider)
        expect(user.uid).to eq(auth.uid)
        expect(user.email).to eq(auth.info.email)
        expect(user.name).to eq(auth.info.name)
        expect(user.image).to eq(auth.info.image)
      end
    end

    context 'when user already exists' do
      let!(:existing_user) { create(:user, provider: 'github', uid: '123545') }

      it 'returns the existing user' do
        expect do
          User.from_omniauth(auth)
        end.to_not(change { User.count })

        expect(User.from_omniauth(auth)).to eq(existing_user)
      end
    end
  end
end
