#!/usr/bin/env bash

# Safeties on: https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euo pipefail

docker-compose build app > /dev/null 2>&1 || docker-compose build app
docker-compose run --no-deps --rm app "$@"
