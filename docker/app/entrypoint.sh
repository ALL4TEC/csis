#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /var/www/csis/tmp/pids/server.pid

# Wait for db to be started
host="csis-db"
cmd="$@"

until psql -h "$host" -U "postgres" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

# Then exec the container's main process (what's set as CMD in the Dockerfile).
>&2 echo "Postgres is up - executing command"
>&2 echo $cmd
exec $cmd
