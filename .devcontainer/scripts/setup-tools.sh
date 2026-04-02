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
# Configure Neovim
# -----------------------------------------------------------------------------
echo "Configuring Neovim..."

mkdir -p "${HOME}/.config/nvim"

cat > "${HOME}/.config/nvim/init.lua" << 'NVIM_CONFIG'
-- =============================================================================
-- AI Dev Container - Neovim Configuration
-- Minimal but functional setup with LSP support
-- =============================================================================

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.local/share/nvim/undo")
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.colorcolumn = "100"
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"

-- Leader key
vim.g.mapleader = " "

-- Key mappings
vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Open file explorer" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up centered" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search centered" })

-- Visual mode: move selected lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better paste (doesn't overwrite register)
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwrite" })

-- Copy to system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = "Copy to clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Copy line to clipboard" })

-- Delete without yanking
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]], { desc = "Delete without yank" })

-- Quick fix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Next quickfix" })
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Previous quickfix" })

-- Search and replace word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Search/replace word" })

-- Make file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make executable" })

-- Colorscheme (built-in)
vim.cmd.colorscheme("habamax")

-- Netrw settings (file explorer)
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

print("Neovim ready! Use :help for documentation")
NVIM_CONFIG

# Create undo directory
mkdir -p "${HOME}/.local/share/nvim/undo"

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
