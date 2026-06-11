#!/usr/bin/env bash
set -euo pipefail
# stop.sh — close Space Rangers and clean up the container + any leftover windows.

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Close any Space Rangers windows (including off-screen zombies from crashes).
for id in $(xdotool search --name "Space Rangers" 2>/dev/null || true); do
  xdotool windowkill "$id" 2>/dev/null || true
done

docker compose rm -sf godot >/dev/null 2>&1 || true
docker ps -aq --filter name=space-rangers-godot | xargs -r docker rm -f >/dev/null 2>&1 || true
echo "Stopped Space Rangers and cleaned up."
