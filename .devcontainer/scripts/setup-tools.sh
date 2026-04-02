#!/bin/bash
# =============================================================================
# AI Dev Container - Post-install Setup Script
# Installs npm packages, pip packages, and configures tools
# =============================================================================

set -e

echo "Setting up AI development tools..."

# -----------------------------------------------------------------------------
# Source environment
# -----------------------------------------------------------------------------
export HOME="/home/dev"
export PATH="${HOME}/.local/share/fnm:${HOME}/.local/bin:${HOME}/.cargo/bin:${HOME}/.deno/bin:${HOME}/.bun/bin:${HOME}/go/bin:/usr/local/go/bin:${PATH}"

# Initialize fnm
eval "$(${HOME}/.local/share/fnm/fnm env)"

# -----------------------------------------------------------------------------
# Install Global npm Packages (AI Tools + Language Servers)
# -----------------------------------------------------------------------------
echo "Installing npm global packages..."

# AI Coding Tools
# Note: Some AI tools require manual installation or are installed via other methods
npm install -g @anthropic-ai/claude-code || echo "Claude Code installation may require manual setup"

# Language Servers
npm install -g \
    typescript \
    typescript-language-server \
    vscode-langservers-extracted \
    yaml-language-server \
    dockerfile-language-server-nodejs \
    bash-language-server

# Utilities
npm install -g \
    prettier \
    eslint \
    npm-check-updates \
    tldr

# -----------------------------------------------------------------------------
# Install OpenCode CLI
# -----------------------------------------------------------------------------
echo "Installing OpenCode CLI..."

# OpenCode can be installed via the official installer script
# Check https://opencode.ai for the latest installation method
curl -fsSL https://opencode.ai/install | bash 2>/dev/null || {
    echo "OpenCode installer not available, trying alternative methods..."
    # Try cargo install as fallback (if available on crates.io)
    cargo install opencode 2>/dev/null || echo "OpenCode: Install manually from https://opencode.ai"
}

# -----------------------------------------------------------------------------
# Install Gemini CLI
# -----------------------------------------------------------------------------
echo "Installing Gemini CLI..."

# Google's Gemini CLI can be run via npx or installed globally
# Using npm package if available, otherwise set up npx alias
npm install -g @google/gemini-cli 2>/dev/null || {
    echo "Gemini CLI: Use 'npx @google/gemini-cli' or install from Google's official source"
}

# -----------------------------------------------------------------------------
# Install Python Packages with uv
# -----------------------------------------------------------------------------
echo "Installing Python packages with uv..."

# Ensure uv is in path
export PATH="${HOME}/.cargo/bin:${PATH}"

# Install aider-chat
uv tool install aider-chat

# Install other Python tools
uv tool install ruff
uv tool install black
uv tool install mypy
uv tool install pyright

# -----------------------------------------------------------------------------
# Install Deno Tools
# -----------------------------------------------------------------------------
echo "Installing Deno tools..."

# Gemini CLI via Deno (official Google method)
# https://github.com/anthropics/gemini-cli uses npx, we'll set up an alias instead

# -----------------------------------------------------------------------------
# Install Go Tools
# -----------------------------------------------------------------------------
echo "Installing Go tools..."

export GOPATH="${HOME}/go"
export PATH="${GOPATH}/bin:/usr/local/go/bin:${PATH}"

go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# -----------------------------------------------------------------------------
# Install Rust Tools
# -----------------------------------------------------------------------------
echo "Installing Rust tools..."

source "${HOME}/.cargo/env"

# rust-analyzer already installed via rustup

# -----------------------------------------------------------------------------
# Install GitHub Copilot CLI Extension
# -----------------------------------------------------------------------------
echo "Setting up GitHub CLI extensions..."

# Note: gh copilot requires authentication, just install the extension
gh extension install github/gh-copilot 2>/dev/null || echo "gh-copilot extension will be available after 'gh auth login'"

# -----------------------------------------------------------------------------
# Configure Neovim (LazyVim)
# -----------------------------------------------------------------------------
echo "Configuring Neovim (LazyVim)..."

NVIM_CONFIG_DIR="${HOME}/.config/nvim"
NVIM_DATA_DIR="${HOME}/.local/share/nvim"
NVIM_STATE_DIR="${HOME}/.local/state/nvim"
NVIM_CACHE_DIR="${HOME}/.cache/nvim"

if [ -d "${NVIM_CONFIG_DIR}" ] && [ -f "${NVIM_CONFIG_DIR}/lazyvim.json" ]; then
    echo "LazyVim already configured at ${NVIM_CONFIG_DIR}"
elif [ -d "${NVIM_CONFIG_DIR}" ] && [ "$(ls -A "${NVIM_CONFIG_DIR}")" ]; then
    NVIM_BACKUP_DIR="${HOME}/.config/nvim.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing Neovim config to ${NVIM_BACKUP_DIR}"
    mv "${NVIM_CONFIG_DIR}" "${NVIM_BACKUP_DIR}"
fi

if [ ! -d "${NVIM_CONFIG_DIR}" ]; then
    git clone https://github.com/LazyVim/starter "${NVIM_CONFIG_DIR}"
    rm -rf "${NVIM_CONFIG_DIR}/.git"
fi

mkdir -p "${NVIM_DATA_DIR}" "${NVIM_STATE_DIR}" "${NVIM_CACHE_DIR}"

if command -v nvim >/dev/null 2>&1; then
    nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 || echo "Run 'nvim' once to complete plugin installation"
fi

# -----------------------------------------------------------------------------
# Configure Git
# -----------------------------------------------------------------------------
echo "Configuring Git..."

git config --global init.defaultBranch main
git config --global core.editor nvim
git config --global pull.rebase false
git config --global push.autoSetupRemote true
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.lg "log --oneline --graph --decorate"

# -----------------------------------------------------------------------------
# Create helper scripts
# -----------------------------------------------------------------------------
echo "Creating helper scripts..."

mkdir -p "${HOME}/.local/bin"

# Create a script to sync host configs
cat > "${HOME}/.local/bin/sync-host-config" << 'SYNC_SCRIPT'
#!/bin/bash
# Sync configuration from mounted host config directory
# Usage: sync-host-config

HOST_CONFIG="${HOME}/.host-config"

if [ -d "${HOST_CONFIG}" ]; then
    echo "Syncing configurations from host..."
    
    # OpenCode
    if [ -d "${HOST_CONFIG}/opencode" ]; then
        mkdir -p "${HOME}/.config/opencode"
        cp -r "${HOST_CONFIG}/opencode/"* "${HOME}/.config/opencode/" 2>/dev/null
        echo "  - OpenCode config synced"
    fi
    
    # GitHub CLI
    if [ -d "${HOST_CONFIG}/gh" ]; then
        mkdir -p "${HOME}/.config/gh"
        cp -r "${HOST_CONFIG}/gh/"* "${HOME}/.config/gh/" 2>/dev/null
        echo "  - GitHub CLI config synced"
    fi
    
    # Git config
    if [ -f "${HOST_CONFIG}/git/config" ]; then
        cp "${HOST_CONFIG}/git/config" "${HOME}/.gitconfig" 2>/dev/null
        echo "  - Git config synced"
    fi
    
    echo "Done!"
else
    echo "No host config directory found at ${HOST_CONFIG}"
    echo "Mount your ~/.config directory to /home/dev/.host-config"
fi
SYNC_SCRIPT

chmod +x "${HOME}/.local/bin/sync-host-config"

# Create a quick project setup script
cat > "${HOME}/.local/bin/new-project" << 'PROJECT_SCRIPT'
#!/bin/bash
# Quick project scaffolding
# Usage: new-project <type> <name>

TYPE=$1
NAME=$2

if [ -z "$TYPE" ] || [ -z "$NAME" ]; then
    echo "Usage: new-project <type> <name>"
    echo ""
    echo "Types:"
    echo "  node     - Node.js with TypeScript"
    echo "  bun      - Bun with TypeScript"
    echo "  deno     - Deno with TypeScript"
    echo "  python   - Python with uv"
    echo "  go       - Go module"
    echo "  rust     - Rust with Cargo"
    exit 1
fi

mkdir -p "$NAME" && cd "$NAME"

case $TYPE in
    node)
        npm init -y
        npm install -D typescript @types/node tsx
        npx tsc --init
        mkdir -p src
        echo 'console.log("Hello from Node.js!")' > src/index.ts
        echo "Node.js project '$NAME' created!"
        ;;
    bun)
        bun init -y
        echo "Bun project '$NAME' created!"
        ;;
    deno)
        deno init
        echo "Deno project '$NAME' created!"
        ;;
    python)
        uv init
        echo "Python project '$NAME' created!"
        ;;
    go)
        go mod init "$NAME"
        echo 'package main

import "fmt"

func main() {
    fmt.Println("Hello from Go!")
}' > main.go
        echo "Go project '$NAME' created!"
        ;;
    rust)
        cargo init
        echo "Rust project '$NAME' created!"
        ;;
    *)
        echo "Unknown project type: $TYPE"
        exit 1
        ;;
esac
PROJECT_SCRIPT

chmod +x "${HOME}/.local/bin/new-project"

# -----------------------------------------------------------------------------
# Final cleanup
# -----------------------------------------------------------------------------
echo ""
echo "Setup complete!"
echo ""
echo "Available AI tools:"
echo "  - claude       - Claude Code (@anthropic-ai/claude-code)"
echo "  - aider        - AI pair programming (via uv)"
echo "  - gh copilot   - GitHub Copilot CLI (requires 'gh auth login')"
echo ""
echo "Note: Some tools may require API keys or authentication:"
echo "  - ANTHROPIC_API_KEY for Claude"
echo "  - OPENAI_API_KEY for Aider (optional)"
echo "  - 'gh auth login' for GitHub Copilot"
echo ""
