# Claude Code Docker Setup (M1 Mac)

A production-ready Docker setup for running Claude Code in a containerized environment, optimized for M1/M2/M3 Macs.

## Features

- ✅ **Full project access** - Claude has read-write access to your project
- ✅ **Read-only plugins** - Your `~/.claude` config is mounted read-only
- ✅ **M1 optimized** - Native ARM64 platform, `:delegated` volume mounts
- ✅ **Secure** - Container isolation, user mapping, resource limits
- ✅ **Self-contained** - Claude Code v2.0.50 installed in image

## Quick Start

### Installation

#### Option 1: Git Submodule (Recommended)

Add this Docker setup as a git submodule in your project:

```bash
cd ~/code/my-project
git submodule add git@github.com:Kauko/claude-docker-setup.git .docker
cd .docker
./setup-docker.sh
```

Update the `.env` file with your API key:
```bash
echo "ANTHROPIC_API_KEY=your-key-here" >> .docker/.env
```

Build and run:
```bash
docker-compose -f .docker/docker-compose.yml build
docker-compose -f .docker/docker-compose.yml run --rm claude
```

**Benefits:**
- Version locked to a specific commit
- Updates easily with `git submodule update --remote`
- No files pollute your project root
- Git tracks the exact Docker setup version

**Optional:** Create aliases for convenience:
```bash
# Add to ~/.config/fish/config.fish or ~/.bashrc
alias claude-docker="docker-compose -f .docker/docker-compose.yml run --rm claude"
alias claude-docker-build="docker-compose -f .docker/docker-compose.yml build"
```

#### Option 2: Manual Download (Alternative)

If you prefer not to use git submodules, download files directly:

```bash
cd ~/code/my-project
curl -sL https://github.com/Kauko/claude-docker-setup/archive/main.tar.gz | \
  tar xz --strip-components=1 claude-docker-setup-main/{Dockerfile,docker-compose.yml,.dockerignore,setup-docker.sh,.env.example,README.docker.md}
chmod +x setup-docker.sh
./setup-docker.sh
docker-compose build
docker-compose run --rm claude
```

**Note:** With this approach, add these files to your `.gitignore`:
```gitignore
# Claude Docker setup
Dockerfile
docker-compose.yml
.dockerignore
setup-docker.sh
.env
.env.example
README.docker.md
```

## Usage

If using git submodule approach, prefix commands with `-f .docker/docker-compose.yml`:

### Interactive Session
```bash
# With submodule
docker-compose -f .docker/docker-compose.yml run --rm claude

# With manual download (files in root)
docker-compose run --rm claude
```

### One-off Task
```bash
# With submodule
docker-compose -f .docker/docker-compose.yml run --rm task "analyze this codebase"

# With manual download
docker-compose run --rm task "analyze this codebase"
```

### Custom Flags
```bash
# Without --dangerously-skip-permissions
CLAUDE_FLAGS="" docker-compose -f .docker/docker-compose.yml run --rm claude

# With different flags
CLAUDE_FLAGS="--verbose" docker-compose -f .docker/docker-compose.yml run --rm claude
```

### Manual Exploration
```bash
docker-compose -f .docker/docker-compose.yml run --rm bash
```

## Configuration

The `.env` file (created by setup script):

```bash
# Required
ANTHROPIC_API_KEY=your-key-here

# User/Group IDs (macOS defaults)
UID=501
GID=20

# Claude flags
CLAUDE_FLAGS=--dangerously-skip-permissions

# Git configuration for commits in container
GIT_AUTHOR_NAME=Claude Code
GIT_AUTHOR_EMAIL=claude@container
```

## What Gets Mounted

```
/workspace          → Your project directory (read-write)
/home/node/.claude  → Your ~/.claude config (read-only)
```

## Security Features

- Container isolation
- User mapping (runs as your UID/GID)
- Minimal Linux capabilities
- Resource limits (4 CPU, 4GB RAM)
- Init system (tini) for proper signal handling
- Read-only plugin directory

## Updating the Docker Setup

### If Using Git Submodule

Pull the latest changes from the submodule:

```bash
cd ~/code/my-project
git submodule update --remote .docker
cd .docker
./setup-docker.sh  # Regenerate .env if needed
docker-compose -f .docker/docker-compose.yml build --no-cache
```

Commit the submodule update:

```bash
git add .docker
git commit -m "Update Docker setup to latest version"
```

### If Using Manual Download

Re-download and replace files (backup your `.env` first):

```bash
cp .env .env.backup
curl -sL https://github.com/Kauko/claude-docker-setup/archive/main.tar.gz | \
  tar xz --strip-components=1 claude-docker-setup-main/{Dockerfile,docker-compose.yml,.dockerignore,setup-docker.sh,.env.example,README.docker.md}
mv .env.backup .env
docker-compose build --no-cache
```

## Requirements

- macOS (M1/M2/M3)
- Docker Desktop for Mac
- Claude Code installed on host (for comparison/plugin management)
- Git (for submodule approach)

## Troubleshooting

### Permission Issues
Run `./setup-docker.sh` to auto-detect your UID/GID.

### API Key Not Set
Add `ANTHROPIC_API_KEY=your-key` to `.env` file.

### Slow Performance
Already optimized with `:delegated` volume mounts for macOS.

## Files Included

- `Dockerfile` - Node 20.18.1 + Claude Code 2.0.50
- `docker-compose.yml` - Service definitions (claude, bash, task)
- `.dockerignore` - Build context exclusions
- `setup-docker.sh` - Auto-configuration script
- `.env.example` - Configuration template
- `README.docker.md` - Detailed documentation

## License

MIT

## Contributing

Issues and PRs welcome!
