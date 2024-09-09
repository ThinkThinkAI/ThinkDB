#!/bin/bash
set -e

export REDIS_URL=redis://redis:6379/1

rm -f /app/tmp/pids/server.pid

bundle exec rails db:migrate

exec "$@"
