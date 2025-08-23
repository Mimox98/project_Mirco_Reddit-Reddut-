#!/usr/bin/env bash
set -o errexit

bundle install
bin/rails assets:precompile
bin/rails assets:clean
# On the free plan, run migrations during build:
bin/rails db:migrate
if [ "${SEED_ON_DEPLOY}" = "true" ]; then
  echo "Seeding database..."
  bin/rails db:seed
fi
