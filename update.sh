#!/usr/bin/env bash

WEBHOOK_URL=$OTS_NOTIFICATIONS_WEBHOOK_URL
TAG=$1

# Function to send a webhook notification
send_webhook() {
  local message="$1"
  curl -H "Content-Type: application/json" -d "{ \"content\": \"<@120924233873227776> $message\" }"  -m 10 "$WEBHOOK_URL" || true
}

exit_failure() {
  send_webhook "Auto-release $TAG failed"
  exit "$1"
}

# Initial webhook notification
send_webhook "Starting ots release for tag $1"

# Check if a tag is provided
if [ -z "$1" ]; then
  send_webhook "Script failed: release invoked without valid tag in payload"
  echo "Usage: $0 <git-tag>"
  exit 1
fi

# Step 1: Checkout the provided tag
echo "Checking out tag $TAG..."
git fetch --tags
git checkout tags/$TAG -b $TAG-branch || exit_failure 1

# Step 2: Run bundle install
echo "Running bundle install..."
bundle install || exit_failure 1

# Step 3: Run yarn install
echo "Running yarn install..."
yarn install || exit_failure 1

# Step 4: Precompile assets
echo "Precompiling assets..."
./bin/rails assets:precompile || exit_failure 1

# Step 5: Restart the Rails server
echo "Restarting Rails server..."

# Assuming a pid file exists which tracks the server's process id
# Adjust the path to the pid file as necessary
PID_FILE='tmp/pids/server.pid'

if [ -f $PID_FILE ]; then
  PID=$(cat $PID_FILE)
  if kill -0 $PID > /dev/null 2>&1; then
    echo "Killing existing Rails server with PID: $PID"
    kill -9 $PID
    # Wait a moment to ensure the process has been stopped
    sleep 1
  else
    echo "No running server found with PID: $PID. The PID file might be stale."
  fi
else
  echo "No PID file found. Assuming no server is running."
fi

# Assuming you want to start the rails server in the background
echo "Starting Rails server..."
./bin/rails server -d || exit_failure 1

echo "Update and server restart complete."
send_webhook "ots $TAG release complete!"
