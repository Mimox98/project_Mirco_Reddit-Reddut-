#!/usr/bin/env bash
set -o errexit

bundle install
bin/rails assets:precompile
bin/rails assets:clean
# On the free plan, run migrations during build:
bin/rails db:migrate
