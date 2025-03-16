#!/usr/bin/env bash

echo "Booting..."

set -e
set -u

uid="$(stat -c "%u" /app)"
gid="$(stat -c "%g" /app)"

if [ -f ./tmp/pids/server.pid ]
then
  rm ./tmp/pids/server.pid
fi

command=rails

if [ "$#" -gt 0 ]; then
    command="$1"
    shift
fi

case "$command" in
    rails) ./bin/rails s -b 0.0.0.0;;
    vite) DISCORD_ENABLED=0 ./bin/vite dev "$@";;
    *) "$command" "$@";;
esac
