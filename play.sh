#!/usr/bin/env bash
set -euo pipefail
# play.sh — launch Space Rangers and bring its window onto the visible desktop.
#
# Usage: ./play.sh
#
# Why the window-move step exists: under WSLg + Docker, Godot's window renders
# correctly but Weston parks it at huge negative coordinates (~ -32000), so it
# is off-screen. We launch the game, wait for the window, then move it on-screen.

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCENE="${1:-res://src/ui/screens/main_menu/main_menu.tscn}"
IMAGE="space-rangers-godot:${GODOT_VERSION:-4.2.2}"

# Build the image only the first time.
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "Building Godot image (one-time)..."
  env UID="$(id -u)" GID="$(id -g)" docker compose build godot
fi

# Import pass: builds .godot caches incl. the global class registry, so
# `class_name` types resolve when running scenes directly. Cheap after the
# first run (only re-imports changed files); required for correctness.
echo "Importing project..."
env UID="$(id -u)" GID="$(id -g)" docker compose run --rm godot \
  --path /workspace --headless --import >/dev/null 2>&1 || true

echo "Launching $SCENE ..."
env UID="$(id -u)" GID="$(id -g)" docker compose run --rm -d godot \
  --path /workspace --rendering-driver opengl3 --audio-driver Dummy "$SCENE" >/dev/null

# Wait for the window, then move it onto the screen and focus it.
echo "Waiting for window..."
until xdotool search --name "Space Rangers" >/dev/null 2>&1; do sleep 1; done
WID=$(xdotool search --name "Space Rangers" 2>/dev/null | head -1)
xdotool windowmove "$WID" 100 100
xdotool windowactivate "$WID" 2>/dev/null || true
xdotool windowraise "$WID" 2>/dev/null || true
echo "Window is on screen. Close it (or run ./stop.sh) when done."
