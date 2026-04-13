#!/usr/bin/env bash
# deploy.sh — Pull latest code and restart the site on the production VPS.
# Run as root (or sudo) from anywhere on the server:
#   bash /usr/local/lsws/gosmart.health/deploy.sh

set -euo pipefail

PROJECT_DIR="/usr/local/lsws/gosmart.health"
ENV_FILE="/etc/gunicorn-manabu.env"
SETTINGS="mysite.settings.production"
SERVICE="gunicorn-manabu"

echo "==> Pulling latest code..."
cd "$PROJECT_DIR"
git pull

echo "==> Installing / syncing dependencies..."
uv sync --no-group dev

echo "==> Loading environment..."
set -a
source "$ENV_FILE"
set +a

echo "==> Running migrations..."
uv run python manage.py migrate --settings="$SETTINGS"

echo "==> Collecting static files..."
uv run python manage.py collectstatic --noinput --settings="$SETTINGS"

echo "==> Restarting gunicorn..."
systemctl restart "$SERVICE"

echo ""
echo "✓ Deployment complete. Check status with:"
echo "  systemctl status $SERVICE"
