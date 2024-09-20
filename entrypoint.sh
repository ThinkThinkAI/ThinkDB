#!/bin/bash

# Start Redis server on a different port in the background
redis-server --port 6380 --daemonize yes

if [ -z "$SECRET_KEY_BASE" ]; then
  export SECRET_KEY_BASE=$(bin/rails secret)
fi

# Start Sidekiq worker in the background
./sidekiq-entrypoint.sh &
bundle exec sidekiq &


# Exit with the status of the last process to exit
exec "$@"
