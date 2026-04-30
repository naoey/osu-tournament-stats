#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# --- Configuration ---
APP_ROOT="/var/www/osu-tournament-stats"
TAG=$1
WORKING_BRANCH="release/$TAG"
WEBHOOK_URL=$OTS_NOTIFICATIONS_WEBHOOK_URL

# --- Environment Initialization ---
# Manually load fnm and rbenv for a non-interactive shell
export PATH="/home/naoey/.rbenv/bin:/home/naoey/.local/share/fnm:$PATH"
eval "$(rbenv init -)"
eval "$(fnm env --use-on-cd --shell bash)"

# pnpm setup
export PNPM_HOME="/home/naoey/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

cd "$APP_ROOT"

# --- Helper Functions ---
send_discord_webhook() {
  local message="$1"
  curl -H "Content-Type: application/json" \
       -d "{ \"content\": \"<@120924233873227776> $message\" }" \
       -m 10 "$WEBHOOK_URL" || true
}

exit_failure() {
  send_discord_webhook "❌ Deployment of $TAG failed!"
  # Rollback: back to master/main
  git checkout master --force || true
  exit 1
}

# --- Execution ---
send_discord_webhook "🚀 Starting release for tag: $TAG"

echo "Step 1: Fetching and checking out tag..."
git fetch --tags
git checkout "tags/$TAG" -b "$WORKING_BRANCH" || exit_failure

echo "Step 2: Installing Ruby dependencies..."
bundle install --deployment --without development test || exit_failure

echo "Step 3: Installing Node dependencies..."
pnpm install --frozen-lockfile || exit_failure

echo "Step 4: Building assets and migrating..."
export RAILS_ENV=production
# Rails 8+ might require some specific env vars here
bundle exec rails assets:precompile || exit_failure
bundle exec rails db:migrate || exit_failure

echo "Step 5: Restarting systemd service..."
# Requires sudoers configuration for the 'webhook' user
sudo /usr/bin/systemctl restart ots.service

send_discord_webhook "✅ Release $TAG is live!"
echo "Deployment successful."
