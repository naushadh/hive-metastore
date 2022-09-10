#!/usr/bin/env sh

pip install hive-metastore-client > /tmp/out.log || cat /tmp/out.log
./test.py
