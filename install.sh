#!/usr/bin/env bash
# Links Claude Code skills from this repo into ~/.claude/skills.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_dir="$HOME/.claude/skills"

mkdir -p "$target_dir"
for skill in "$repo_dir"/claude/skills/*/; do
  name="$(basename "$skill")"
  ln -sfn "${skill%/}" "$target_dir/$name"
  echo "Linked skill: $name"
done
