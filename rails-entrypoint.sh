#!/bin/bash
set -e
echo "Starting entrypoint.sh"
export REDIS_URL=redis://redis:6379/1

# Ensure SECRET_KEY_BASE is set
if [ -z "$SECRET_KEY_BASE" ]; then
  export SECRET_KEY_BASE=$(bin/rails secret)
fi

echo "Running bundle exec rake assets:precompile"
rm -f /app/tmp/pids/server.pid

echo "Running bundle exec rake assets:precompile"
bundle exec rake assets:precompile RAILS_ENV=production

echo "Running bundle exec rails db:migrate RAILS_ENV=production"
bundle exec rails db:migrate RAILS_ENV=production

echo "Executing final command: $@"
exec "$@"
