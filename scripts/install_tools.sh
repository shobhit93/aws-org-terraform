#!/bin/bash
set -e

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Detect OS
OS="$(uname -s)"
DISTRO=""
ARCH="$(uname -m)"

if [[ "$OS" == "Linux" ]]; then
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        DISTRO=$ID
    fi
fi


# ---------------------
# Install Trivy
# ---------------------
if command_exists trivy; then
    echo "✅ Trivy is already installed!"
    trivy --version || true
else
    echo "⚡ Installing Trivy..."
    if [[ "$OS" == "Darwin" ]]; then
        if ! command_exists brew; then
            echo "❌ Homebrew not found. Install it first: https://brew.sh/"
            exit 1
        fi
        brew install trivy

    elif [[ "$OS" == "Linux" ]]; then
        if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
            echo "Detected $DISTRO ($ARCH). Installing Trivy via apt..."
            sudo apt-get update
            sudo apt-get install -y wget apt-transport-https gnupg lsb-release
            wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
            echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list
            sudo apt-get update
            sudo apt-get install -y trivy
        else
            echo "❌ Unsupported Linux distro: $DISTRO"
            exit 1
        fi

    else
        echo "❌ Unsupported OS: $OS"
        exit 1
    fi

    echo "✅ Trivy installed successfully!"
    trivy --version || true
fi

# ---------------------
# Install detect-secrets
# ---------------------
if command_exists detect-secrets; then
    echo "✅ detect-secrets is already installed!"
    detect-secrets --version || true
else
    echo "⚡ Installing detect-secrets..."
    if [[ "$OS" == "Darwin" ]]; then
        brew install detect-secrets
    elif [[ "$OS" == "Linux" ]]; then
        if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
            sudo apt-get update
            sudo apt-get install -y detect-secrets || {
                echo "Package not found in apt, falling back to GitHub binary..."
                curl -Lo detect-secrets https://github.com/Yelp/detect-secrets/releases/latest/download/detect-secrets-linux
                chmod +x detect-secrets
                sudo mv detect-secrets /usr/local/bin/
            }
        else
            echo "❌ Unsupported Linux distro: $DISTRO"
            exit 1
        fi
    else
        echo "❌ Unsupported OS: $OS"
        exit 1
    fi

    echo "✅ detect-secrets installed successfully!"
    detect-secrets --version || true
fi
