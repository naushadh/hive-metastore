#!/usr/bin/env bash

# Safeties on: https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euo pipefail

DEFAULT_TAG=naushadh/hive-metastore:latest
TAG=${TAG:-$DEFAULT_TAG}

docker build --tag "$TAG" .
docker push "$TAG"
