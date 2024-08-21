#!/usr/bin/env bash

# Safeties on: https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euo pipefail

if [ -z ${VERSION+x} ]; then
    echo "Expected \$VERSION to be defined!";
    exit 1
fi

docker buildx ls | grep multiarch || docker buildx create --name multiarch --use

docker buildx build --push \
    --platform linux/arm64,linux/amd64 \
    --tag "naushadh/hive-metastore:${VERSION}" \
    .
