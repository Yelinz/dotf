#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  Linux)
    exec bash "$repo_dir/setup/arch.sh" "$@"
    ;;
  Darwin)
    exec bash "$repo_dir/setup/macos.sh" "$@"
    ;;
  *)
    echo "Unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac
