#!/bin/bash
set -e

export REDIS_URL=redis://redis:6379/1

exec "$@"
