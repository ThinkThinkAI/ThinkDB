# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'should get omniauth_callbacks' do
    get users_omniauth_callbacks_url
    assert_response :success
  end
end
