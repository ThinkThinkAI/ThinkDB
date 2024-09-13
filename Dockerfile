# Use the official Ruby image as a base
FROM ruby:3.2.2

# Install dependencies
RUN apt-get update -qq
RUN apt-get install -y nodejs postgresql-client libsqlite3-dev build-essential 
RUN apt-get install -y default-libmysqlclient-dev libmariadb-dev-compat

# Set environment variables
ENV RAILS_ENV=production
ENV REDIS_URL=redis://redis:6379/1

# Set the working directory in the container
WORKDIR /app

# Copy the Gemfile and Gemfile.lock files
COPY Gemfile* ./

# Install the Ruby and Rails dependencies
RUN bundle install --without development test

# Copy the application code
COPY . ./

# Copy the entrypoint scripts
COPY entrypoint.sh ./entrypoint.sh
COPY sidekiq-entrypoint.sh ./sidekiq-entrypoint.sh

# Make sure the entrypoint scripts are executable
RUN chmod +x entrypoint.sh sidekiq-entrypoint.sh

# Precompile assets for production
RUN SECRET_KEY_BASE=dummy_key RAILS_ENV=production bundle exec rake assets:precompile

# Expose the application port
EXPOSE 3000

# Default command to run the Rails server
CMD bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0 -p 3000
