# =============================================================================
# AI-Powered Development Container
# Optimized for Apple Silicon (ARM64)
# =============================================================================
# Build: docker build -t ai-dev .devcontainer
# Run:   docker run -it --rm \
#          -v $(pwd):/workspace \
#          -v ~/.ssh:/home/dev/.ssh:ro \
#          -v ~/.config:/home/dev/.host-config:ro \
#          -v ~/.aws:/home/dev/.aws:ro \
#          -v ~/.azure:/home/dev/.azure:ro \
#          -v ~/.config/gcloud:/home/dev/.config/gcloud:ro \
#          -v /var/run/docker.sock:/var/run/docker.sock \
#          -w /workspace \
#          ai-dev
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Builder - Download and prepare binaries
# -----------------------------------------------------------------------------
FROM debian:bookworm-slim AS builder

ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    unzip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Download Go
ARG GO_VERSION=1.22.2
RUN case "${TARGETARCH}" in \
        arm64) GOARCH="arm64" ;; \
        amd64) GOARCH="amd64" ;; \
        *) echo "Unsupported arch: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${GOARCH}.tar.gz" | tar -xz -C /build

# Download lazygit
ARG LAZYGIT_VERSION=0.41.0
RUN case "${TARGETARCH}" in \
        arm64) ARCH="arm64" ;; \
        amd64) ARCH="x86_64" ;; \
    esac && \
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${ARCH}.tar.gz" | tar -xz -C /build && \
    chmod +x /build/lazygit

# Download lazydocker
ARG LAZYDOCKER_VERSION=0.23.1
RUN case "${TARGETARCH}" in \
        arm64) ARCH="arm64" ;; \
        amd64) ARCH="x86_64" ;; \
    esac && \
    curl -fsSL "https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_Linux_${ARCH}.tar.gz" | tar -xz -C /build && \
    chmod +x /build/lazydocker

# Download k9s
ARG K9S_VERSION=0.32.4
RUN case "${TARGETARCH}" in \
        arm64) ARCH="arm64" ;; \
        amd64) ARCH="amd64" ;; \
    esac && \
    curl -fsSL "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_${ARCH}.tar.gz" | tar -xz -C /build && \
    chmod +x /build/k9s

# Download helm
ARG HELM_VERSION=3.14.3
RUN case "${TARGETARCH}" in \
        arm64) ARCH="arm64" ;; \
        amd64) ARCH="amd64" ;; \
    esac && \
    curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz" | tar -xz -C /build --strip-components=1 && \
    chmod +x /build/helm

# Download kubectl
ARG KUBECTL_VERSION=1.29.3
RUN case "${TARGETARCH}" in \
        arm64) ARCH="arm64" ;; \
        amd64) ARCH="amd64" ;; \
    esac && \
    curl -fsSL -o /build/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl" && \
    chmod +x /build/kubectl

# Download yq
ARG YQ_VERSION=4.43.1
RUN case "${TARGETARCH}" in \
        arm64) ARCH="arm64" ;; \
        amd64) ARCH="amd64" ;; \
    esac && \
    curl -fsSL -o /build/yq "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${ARCH}" && \
    chmod +x /build/yq

# Download fd
ARG FD_VERSION=9.0.0
RUN case "${TARGETARCH}" in \
        arm64) ARCH="aarch64" ;; \
        amd64) ARCH="x86_64" ;; \
    esac && \
    curl -fsSL "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-${ARCH}-unknown-linux-gnu.tar.gz" | tar -xz -C /build --strip-components=1 && \
    chmod +x /build/fd

# Download bat
ARG BAT_VERSION=0.24.0
RUN case "${TARGETARCH}" in \
        arm64) ARCH="aarch64" ;; \
        amd64) ARCH="x86_64" ;; \
    esac && \
    curl -fsSL "https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-${ARCH}-unknown-linux-gnu.tar.gz" | tar -xz -C /build --strip-components=1 && \
    chmod +x /build/bat

# Download eza
ARG EZA_VERSION=0.18.9
RUN case "${TARGETARCH}" in \
        arm64) ARCH="aarch64" ;; \
        amd64) ARCH="x86_64" ;; \
    esac && \
    curl -fsSL "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_${ARCH}-unknown-linux-gnu.tar.gz" | tar -xz -C /build && \
    chmod +x /build/eza

# Download ripgrep
ARG RG_VERSION=15.1.0
RUN case "${TARGETARCH}" in \
        arm64) ARCH="aarch64"; LIBC="gnu" ;; \
        amd64) ARCH="x86_64"; LIBC="musl" ;; \
    esac && \
    curl -fsSL "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-${ARCH}-unknown-linux-${LIBC}.tar.gz" | tar -xz -C /build --strip-components=1 && \
    chmod +x /build/rg

# Download fzf
ARG FZF_VERSION=0.48.1
RUN case "${TARGETARCH}" in \
        arm64) ARCH="arm64" ;; \
        amd64) ARCH="amd64" ;; \
    esac && \
    curl -fsSL "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_${ARCH}.tar.gz" | tar -xz -C /build && \
    chmod +x /build/fzf

# Download starship
RUN curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b /build

# Download neovim
ARG NVIM_VERSION=0.12.0
RUN case "${TARGETARCH}" in \
        arm64) \
            curl -fsSL "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-arm64.tar.gz" | tar -xz -C /build --strip-components=1 ;; \
        amd64) \
            curl -fsSL "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-x86_64.tar.gz" | tar -xz -C /build --strip-components=1 ;; \
    esac

# -----------------------------------------------------------------------------
# Stage 2: Runtime - Final optimized image
# -----------------------------------------------------------------------------
FROM debian:bookworm-slim AS runtime

LABEL maintainer="AI Dev Container"
LABEL description="Full-featured AI-powered development environment"

ARG TARGETARCH
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install base system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core utilities
    ca-certificates \
    curl \
    wget \
    unzip \
    xz-utils \
    gnupg \
    lsb-release \
    # Development essentials
    git \
    git-lfs \
    openssh-client \
    # Build tools (needed for some npm packages)
    build-essential \
    # Python
    python3 \
    python3-pip \
    python3-venv \
    # Database clients
    sqlite3 \
    postgresql-client \
    # Misc utilities
    jq \
    less \
    tree \
    htop \
    procps \
    sudo \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Generate locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=${TARGETARCH} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bookworm stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=${TARGETARCH} signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && apt-get install -y --no-install-recommends gh && \
    rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN case "${TARGETARCH}" in \
        arm64) ARCH="aarch64" ;; \
        amd64) ARCH="x86_64" ;; \
    esac && \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o /tmp/awscliv2.zip && \
    unzip -q /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws /tmp/awscliv2.zip

# Install Google Cloud CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    apt-get update && apt-get install -y --no-install-recommends google-cloud-cli && \
    rm -rf /var/lib/apt/lists/*

# Copy binaries from builder stage
COPY --from=builder /build/go /usr/local/go
COPY --from=builder /build/lazygit /usr/local/bin/
COPY --from=builder /build/lazydocker /usr/local/bin/
COPY --from=builder /build/k9s /usr/local/bin/
COPY --from=builder /build/helm /usr/local/bin/
COPY --from=builder /build/kubectl /usr/local/bin/
COPY --from=builder /build/yq /usr/local/bin/
COPY --from=builder /build/fd /usr/local/bin/
COPY --from=builder /build/bat /usr/local/bin/
COPY --from=builder /build/eza /usr/local/bin/
COPY --from=builder /build/rg /usr/local/bin/
COPY --from=builder /build/fzf /usr/local/bin/
COPY --from=builder /build/starship /usr/local/bin/
COPY --from=builder /build/bin/nvim /usr/local/bin/
COPY --from=builder /build/lib /usr/local/lib/
COPY --from=builder /build/share/nvim /usr/local/share/nvim

# Set up Go environment
ENV GOROOT=/usr/local/go
ENV PATH="${GOROOT}/bin:${PATH}"

# Create non-root user
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

# Add user to docker group for socket access
RUN groupadd -f docker && usermod -aG docker ${USERNAME}

# Switch to non-root user for remaining setup
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Set up user environment paths
ENV HOME=/home/${USERNAME}
ENV PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${HOME}/.deno/bin:${HOME}/.bun/bin:${HOME}/go/bin:${PATH}"
ENV GOPATH="${HOME}/go"

# Install fnm (Fast Node Manager)
RUN curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell && \
    export PATH="${HOME}/.local/share/fnm:${PATH}" && \
    eval "$(${HOME}/.local/share/fnm/fnm env)" && \
    fnm install --lts && \
    fnm default lts-latest

ENV PATH="${HOME}/.local/share/fnm:${PATH}"

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Install Deno
RUN curl -fsSL https://deno.land/install.sh | sh

# Install Rust via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal && \
    . "${HOME}/.cargo/env" && \
    rustup component add rust-analyzer

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Create directories for tool configs
RUN mkdir -p "${HOME}/.config" "${HOME}/.local/bin" "${HOME}/.ssh" "${HOME}/go"

# Copy configuration files
COPY --chown=${USERNAME}:${USERNAME} config/starship.toml ${HOME}/.config/starship.toml
COPY --chown=${USERNAME}:${USERNAME} scripts/setup-tools.sh /tmp/setup-tools.sh

# Run setup script to install npm/pip packages and configure tools
RUN chmod +x /tmp/setup-tools.sh && /tmp/setup-tools.sh

# Configure bash
RUN echo '\n\
# =============================================================================\n\
# AI Dev Container - Bash Configuration\n\
# =============================================================================\n\
\n\
# Starship prompt\n\
eval "$(starship init bash)"\n\
\n\
# fnm (Node.js)\n\
eval "$(fnm env --use-on-cd)"\n\
\n\
# fzf key bindings and completion\n\
eval "$(fzf --bash)"\n\
\n\
# Aliases - Modern CLI replacements\n\
alias ls="eza --icons --group-directories-first"\n\
alias ll="eza -la --icons --group-directories-first"\n\
alias lt="eza --tree --icons --level=2"\n\
alias cat="bat --paging=never"\n\
alias grep="rg"\n\
alias find="fd"\n\
alias vim="nvim"\n\
alias vi="nvim"\n\
\n\
# Git aliases\n\
alias g="git"\n\
alias gs="git status"\n\
alias ga="git add"\n\
alias gc="git commit"\n\
alias gp="git push"\n\
alias gl="git pull"\n\
alias gd="git diff"\n\
alias gco="git checkout"\n\
alias gb="git branch"\n\
alias lg="lazygit"\n\
alias ld="lazydocker"\n\
\n\
# Kubernetes aliases\n\
alias k="kubectl"\n\
alias kgp="kubectl get pods"\n\
alias kgs="kubectl get services"\n\
alias kgd="kubectl get deployments"\n\
\n\
# Docker aliases\n\
alias d="docker"\n\
alias dc="docker compose"\n\
alias dps="docker ps"\n\
alias di="docker images"\n\
\n\
# AI tools\n\
alias oc="opencode"\n\
alias ai="aider"\n\
\n\
# Environment\n\
export EDITOR="nvim"\n\
export VISUAL="nvim"\n\
export PAGER="less -R"\n\
\n\
# History settings\n\
export HISTSIZE=10000\n\
export HISTFILESIZE=20000\n\
export HISTCONTROL=ignoreboth:erasedups\n\
shopt -s histappend\n\
\n\
# Enable programmable completion\n\
if [ -f /etc/bash_completion ]; then\n\
    . /etc/bash_completion\n\
fi\n\
\n\
# Welcome message\n\
echo ""\n\
echo "  AI Development Container"\n\
echo "  ─────────────────────────────────────────"\n\
echo "  Node: $(node --version 2>/dev/null || echo "loading...")  Bun: $(bun --version 2>/dev/null)"\n\
echo "  Deno: $(deno --version 2>/dev/null | head -1 | cut -d" " -f2)  Python: $(python3 --version | cut -d" " -f2)"\n\
echo "  Go: $(go version | cut -d" " -f3)  Rust: $(rustc --version | cut -d" " -f2)"\n\
echo ""\n\
echo "  AI Tools: opencode, claude, aider, gemini, gh copilot"\n\
echo "  Type \"help-ai\" for usage tips"\n\
echo ""\n\
\n\
# Help function\n\
help-ai() {\n\
    echo ""\n\
    echo "  AI Coding Tools"\n\
    echo "  ────────────────"\n\
    echo "  opencode      - OpenCode CLI (Anthropic-powered)"\n\
    echo "  claude        - Claude Code CLI"\n\
    echo "  aider         - AI pair programming"\n\
    echo "  gemini        - Google Gemini CLI"\n\
    echo "  gh copilot    - GitHub Copilot CLI"\n\
    echo ""\n\
    echo "  Quick Commands"\n\
    echo "  ──────────────"\n\
    echo "  lg            - lazygit (TUI for git)"\n\
    echo "  ld            - lazydocker (TUI for docker)"\n\
    echo "  k9s           - Kubernetes TUI"\n\
    echo ""\n\
}\n\
' >> "${HOME}/.bashrc"

# Set default shell
SHELL ["/bin/bash", "-c"]

# Default working directory for mounted workspace
WORKDIR /workspace

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node --version && python3 --version && go version

CMD ["/bin/bash"]
