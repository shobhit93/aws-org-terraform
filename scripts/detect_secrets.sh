#!/bin/bash
set -euo pipefail

# Determine repo root (not pre-commit temp dir)
REPO_ROOT="$(git rev-parse --show-toplevel)"
BASELINE="$REPO_ROOT/.secrets.baseline"

echo "🔍 Detect-secrets directory: $REPO_ROOT"
echo "🔍 Baseline file: $BASELINE"

# Check if detect-secrets is installed
if ! command -v detect-secrets >/dev/null 2>&1; then
    echo "❌ detect-secrets is not installed. Install it first."
    exit 1
fi

# Create baseline if it doesn't exist
if [[ ! -f "$BASELINE" ]]; then
    echo "🆕 No baseline found — generating one..."
    detect-secrets scan > "$BASELINE"
    echo "✅ Baseline created at: $BASELINE"
else
    echo "📄 Baseline exists — using: $BASELINE"
fi

# Run scan against baseline
echo "🔎 Running detect-secrets scan..."
detect-secrets scan --baseline "$BASELINE"

echo "✅ Secret scan completed successfully!"
