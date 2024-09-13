# Use the official Ruby image as a base
FROM ruby:3.2.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client libsqlite3-dev build-essential

# Set the working directory in the container
WORKDIR /app

# Copy the Gemfile and Gemfile.lock files
COPY Gemfile* ./

# Install the Ruby and Rails dependencies
RUN bundle install

# Copy the application code
COPY . ./

# Ensure the entrypoint scripts are included in the image
COPY entrypoint.sh ./entrypoint.sh
COPY sidekiq-entrypoint.sh ./sidekiq-entrypoint.sh

# Make sure the entrypoint scripts are executable
RUN chmod +x entrypoint.sh sidekiq-entrypoint.sh

EXPOSE 3000
# Define the default command to be run in the container
RUN SECRET_KEY_BASE=dummy_key RAILS_ENV=production bundle exec rake assets:precompile


# Copy both entrypoint scripts and make them executable
COPY entrypoint.sh /usr/bin/
COPY sidekiq-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/sidekiq-entrypoint.sh

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]