#!/bin/bash
set -e
echo "Starting entrypoint.sh"
export REDIS_URL=redis://redis:6379/1

export SECRET_KEY_BASE=$(bin/rails secret)

rm -f /app/tmp/pids/server.pid

echo "Running bundle exec rake assets:precompile"
bundle exec rake assets:precompile

echo "Running bundle exec rails db:migrate"
bundle exec rails db:migrate

echo "Executing final command: $@"
exec "$@"
