#!/bin/bash
# create-pilot-id.sh - 生成唯一的 Pilot ID

timestamp=$(date +%Y%m%d-%H%M%S)
echo "pilot-${timestamp}"
