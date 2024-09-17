#!/bin/bash

# Call the first entrypoint script
./rails-entrypoint.sh

# Call the second entrypoint script
./sidekiq-entrypoint.sh

# Finally, execute the command passed to the Docker container
exec "$@"
