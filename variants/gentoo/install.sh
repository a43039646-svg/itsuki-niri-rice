#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
ITSUKI_DISTRO=gentoo exec bash "$ROOT/install.sh"
