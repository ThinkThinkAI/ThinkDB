#!/bin/bash
set -e

# Ensure Redis URL is set correctly
export REDIS_URL=redis://redis:6379/1

# Ensure SECRET_KEY_BASE is set
if [ -z "$SECRET_KEY_BASE" ]; then
  export SECRET_KEY_BASE=$(bin/rails secret)
fi

# Migrate the database before starting Sidekiq
bundle exec rails db:migrate RAILS_ENV=production

exec "$@"
