#!/usr/bin/env sh

set -euxo

flake8 --max-line-length=160
mypy --strict --cache-dir=/dev/null .
python -m unittest
