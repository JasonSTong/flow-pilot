#!/bin/bash
# get-active-pilot.sh - 获取当前活跃的 Pilot

pilots_dir=".claude/pilots"

# 检查目录是否存在
if [ ! -d "$pilots_dir" ]; then
  echo "None"
  exit 0
fi

# 查找 status = "executing" 的 Pilot
for dir in "$pilots_dir"/pilot-*; do
  if [ -d "$dir" ] && [ -f "$dir/progress.json" ]; then
    status=$(jq -r '.status // "unknown"' "$dir/progress.json" 2>/dev/null)

    if [ "$status" = "executing" ]; then
      pilot_id=$(basename "$dir")
      title=$(jq -r '.title // "Unknown"' "$dir/context.json" 2>/dev/null)
      echo "📋 $title (Status: $status)"
      echo "File: $pilot_id"
      exit 0
    fi
  fi
done

# 如果没有 executing，查找 paused
for dir in "$pilots_dir"/pilot-*; do
  if [ -d "$dir" ] && [ -f "$dir/progress.json" ]; then
    status=$(jq -r '.status // "unknown"' "$dir/progress.json" 2>/dev/null)

    if [ "$status" = "paused" ]; then
      pilot_id=$(basename "$dir")
      echo "⏸️  Paused Pilot: $pilot_id"
      exit 0
    fi
  fi
done

echo "None"
