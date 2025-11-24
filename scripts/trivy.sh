#!/bin/bash
set -euo pipefail

if ! command -v trivy >/dev/null 2>&1; then
  echo "❌ Trivy is not installed."
  exit 1
fi

echo "🧹 Full Trivy cache reset (and REMOVE policy dir)..."
export TRIVY_CACHE_DIR="${TRIVY_CACHE_DIR:-$HOME/.cache/trivy}"

# ❗ The important part: wipe the ENTIRE cache and DO NOT recreate policy folder
rm -rf "$TRIVY_CACHE_DIR"

# 🔥 Disable ALL remote downloads (guaranteed)
export TRIVY_SKIP_POLICY_DOWNLOAD=true
export TRIVY_SKIP_DB_UPDATE=true
export TRIVY_SKIP_UPDATE=true
export TRIVY_CHECKS_BUNDLE=off

# ❗ Make sure TRIVY_POLICY_PATH is NOT set at all
unset TRIVY_POLICY_PATH

echo "----------------------------------------"
echo "▶️ Running Trivy IaC Scan (embedded-only)"
echo "----------------------------------------"

TARGET_DIR="$(git rev-parse --show-toplevel)"
echo "Target dir: $TARGET_DIR"

trivy config \
  --exit-code 1 \
  --severity CRITICAL,HIGH \
  --format sarif \
  --output trivy-iac.sarif \
  "$TARGET_DIR"


echo "✅ Trivy IaC SARIF written to trivy-iac.sarif"
