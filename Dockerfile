# Use the official Ruby image as a base
FROM ruby:3.2.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

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

# Define the default command to be run in the container
CMD ["bash"]
