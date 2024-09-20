#!/bin/bash

# Start Redis server on a different port in the background
redis-server --port 6380 --daemonize yes

if [ -z "$SECRET_KEY_BASE" ]; then
  export SECRET_KEY_BASE=$(bin/rails secret)
fi

echo "Running bundle exec rake assets:precompile"
rm -f /app/tmp/pids/server.pid
echo "Running bundle exec rake assets:precompile"
bundle exec rake assets:precompile RAILS_ENV=production
echo "Running bundle exec rails db:migrate RAILS_ENV=production"
bundle exec rails db:migrate RAILS_ENV=production

# Start Sidekiq worker in the background
./sidekiq-entrypoint.sh &
bundle exec sidekiq &


# Exit with the status of the last process to exit
exec "$@"
