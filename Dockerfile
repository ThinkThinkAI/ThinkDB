# Use the official Ruby image with the latest version of Ruby 3.2
FROM ruby:3.2.2

# Set an environment variable to prevent the installation of documentation for Ruby gems
ENV BUNDLE_WITHOUT="development test docs"

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libmariadb-dev-compat libmariadb-dev libpq-dev

RUN apt-get update -qq && apt-get install -y nodejs yarn

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock ./

# Install bundle dependencies
RUN bundle install

# Copy the rest of the application code into the container
COPY . .

# Expose port 3000 to the outside world
EXPOSE 3000

# Precompile assets for production environment
RUN bundle exec rake assets:precompile

# Command to run the application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
