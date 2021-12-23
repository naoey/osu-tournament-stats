#!/usr/bin/env bash

echo "Booting rails app..."

set -e
set -u

uid="$(stat -c "%u" /app)"
gid="$(stat -c "%g" /app)"

if [ -f ./tmp/pids/server.pid ]
then
  rm ./tmp/pids/server.pid
fi

command=serve

if [ "$#" -gt 0 ]; then
    command="$1"
    shift
fi

_serve() {
  ruby --version
  ./bin/rails s -b 0.0.0.0
}

_wds() {
  node --version
  yarn --version
  yarn install
  ./bin/webpack-dev-server
}

case "$command" in
    rails) ./bin/rails "$@";;
    serve|wds) "_$command" "$@";;
    *) "$command" "$@";;
esac
