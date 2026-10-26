#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
ITSUKI_DISTRO=debian exec bash "$ROOT/install.sh"
