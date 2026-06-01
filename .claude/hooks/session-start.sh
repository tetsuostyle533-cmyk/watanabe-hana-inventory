#!/bin/bash
set -euo pipefail

# Pure static HTML project — no dependencies to install.
# This hook runs only in remote (web) environments.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

echo "Session start: no dependencies to install (static HTML project)."
