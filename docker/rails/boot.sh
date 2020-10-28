#!/usr/bin/env bash

echo "Booting rails app..."

ruby --version
node --version
yarn --version

if [ -f ./tmp/pids/server.pid ]
then
  rm ./tmp/pids/server.pid
fi

./bin/rails s -b 0.0.0.0
