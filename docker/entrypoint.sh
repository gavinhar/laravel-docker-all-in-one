#!/bin/bash

set -e

echo "⏳ Starting Laravel entrypoint..."

# OPTIONAL: Wait for .env to be injected by the runtime (like with Kubernetes secrets)
if [ ! -f ".env" ]; then
  echo "⚠️ .env file not found."
  exit 1
fi

# Clear and regenerate caches
echo "🔁 Clearing Laravel caches..."
php artisan optimize:clear

echo "⚙️ Caching Laravel config, routes, and views..."
php artisan optimize

# Run database migrations
echo "🗄️ Running migrations..."
php artisan migrate --force

# Start the application
echo "🚀 Starting supervisord (nginx + php-fpm + inertia SSR)..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
