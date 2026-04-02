# Use the Prebuilt Docker Image as a VS Code Dev Container

This project ships a Dockerfile at `.devcontainer/Dockerfile` with a full development toolchain.

Use this guide if you want to:
- build the image once,
- reuse it locally, and
- open the repo in VS Code using that prebuilt image.

## Prerequisites

- Docker Desktop (or Docker Engine) running
- VS Code
- VS Code extension: **Dev Containers** (`ms-vscode-remote.remote-containers`)

## 1) Build the image

From the repository root:

```bash
docker build -t ai-dev:local .devcontainer
```

If you need a specific platform:

```bash
docker build --platform linux/arm64 -t ai-dev:local .devcontainer
```

## 2) Create a `devcontainer.json` that uses the image

Create `.devcontainer/devcontainer.json`:

```json
{
  "name": "AI Dev (prebuilt image)",
  "image": "ai-dev:local",
  "remoteUser": "dev",
  "workspaceFolder": "/workspace",
  "mounts": [
    "source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind",
    "source=${localEnv:HOME}/.ssh,target=/home/dev/.ssh,type=bind,readonly",
    "source=${localEnv:HOME}/.config,target=/home/dev/.host-config,type=bind,readonly",
    "source=${localEnv:HOME}/.aws,target=/home/dev/.aws,type=bind,readonly",
    "source=${localEnv:HOME}/.azure,target=/home/dev/.azure,type=bind,readonly",
    "source=${localEnv:HOME}/.config/gcloud,target=/home/dev/.config/gcloud,type=bind,readonly"
  ],
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode-remote.remote-containers"
      ]
    }
  }
}
```

Notes:
- `image` tells VS Code to use the prebuilt image instead of rebuilding.
- The Docker socket mount enables Docker commands from inside the container.
- Cloud and SSH mounts are optional; remove anything you do not need.

## 3) Open the repo in the container

1. Open the repo in VS Code.
2. Run command palette: **Dev Containers: Reopen in Container**.
3. Wait for container startup.

After startup, the project opens at `/workspace` as user `dev`.

## 4) Rebuild the image when Dockerfile changes

If `.devcontainer/Dockerfile` changes, rebuild and reopen:

```bash
docker build -t ai-dev:local .devcontainer
```

Then in VS Code run:
- **Dev Containers: Rebuild Container**

## Optional: Use a registry image instead of local image

If you push your image to a registry, set:

```json
"image": "ghcr.io/<org>/<image>:<tag>"
```

Then teammates can use the same dev environment without local builds.

## Troubleshooting

- `Cannot connect to the Docker daemon`
  - Ensure Docker Desktop is running.
  - Ensure the Docker socket mount exists in `devcontainer.json`.
- Permission issues with mounted files
  - Confirm `remoteUser` is `dev` (matches the Dockerfile setup).
- Container does not pick up new image
  - Rebuild image and run **Dev Containers: Rebuild Container**.
