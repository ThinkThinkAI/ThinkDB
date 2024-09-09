#!/bin/bash
set -e

export REDIS_URL=redis://redis:6379/1

export SECRET_KEY_BASE=$(bin/rails secret)

rm -f /app/tmp/pids/server.pid

bundle exec rake assets:precompile

bundle exec rails db:migrate

exec "$@"
