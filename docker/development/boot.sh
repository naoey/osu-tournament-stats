#!/usr/bin/env bash

echo "Booting rails app..."

ruby --version
node --version
yarn --version

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
  ./bin/rails s -b 0.0.0.0
}

_wds() {
  yarn install
  ./bin/webpack-dev-server
}

case "$command" in
    rails) ./bin/rails "$@";;
    serve|wds) "_$command" "$@";;
    *) "$command" "$@";;
esac
