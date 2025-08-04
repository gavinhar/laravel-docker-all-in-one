#!/bin/bash

set -e

echo "⏳ Starting Laravel entrypoint..."

# OPTIONAL: Wait for .env to be injected by the runtime (like with Kubernetes secrets)
if [ ! -f ".env" ]; then
  echo "⚠️  .env file not found. Waiting for it to appear..."
  while [ ! -f ".env" ]; do sleep 1; done
  echo "✅ .env file detected."
fi

# Clear and regenerate caches
echo "🔁 Clearing Laravel caches..."
php artisan optimize:clear

echo "⚙️ Caching Laravel config, routes, and views..."
php artisan optimize

# OPTIONAL: Run database migrations
if [ "$RUN_MIGRATIONS" = "true" ]; then
  echo "🗄️ Running migrations..."
  php artisan migrate --force
fi

echo "🚀 Starting supervisord (nginx + php-fpm + inertia SSR)..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
