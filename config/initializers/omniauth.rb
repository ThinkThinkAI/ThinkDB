# frozen_string_literal: true

# config/initializers/omniauth.rb

# Configure OmniAuth to allow both GET and POST request methods for callbacks
OmniAuth.config.allowed_request_methods = %i[get post]

# Silence OmniAuth GET warning
OmniAuth.config.silence_get_warning = true
