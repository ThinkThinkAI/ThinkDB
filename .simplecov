# frozen_string_literal: true

SimpleCov.start do
  add_filter 'app/channels'
  add_filter 'app/jobs'
  add_filter 'app/mailers'
  add_filter 'app/controllers/users/omniauth_callbacks_controller.rb'
end
