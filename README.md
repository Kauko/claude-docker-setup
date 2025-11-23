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

#### Option 1: Using Fish Function (Recommended)

Add this to your `~/.config/fish/config.fish`:

```fish
function claude-docker-init
    set repo_url "https://github.com/YOUR_USERNAME/claude-docker-setup"

    echo "🐳 Initializing Claude Docker setup from GitHub..."

    curl -sL "$repo_url/archive/main.tar.gz" | tar xz --strip-components=1 claude-docker-setup-main/{Dockerfile,docker-compose.yml,.dockerignore,setup-docker.sh,.env.example,README.docker.md}

    chmod +x setup-docker.sh

    echo "✅ Files downloaded from $repo_url"
    echo ""
    echo "Next steps:"
    echo "  1. ./setup-docker.sh"
    echo "  2. Add ANTHROPIC_API_KEY to .env"
    echo "  3. docker-compose build"
    echo "  4. docker-compose run --rm claude"
end
```

Then in any project:
```bash
cd ~/code/my-project
claude-docker-init
./setup-docker.sh
docker-compose build
docker-compose run --rm claude
```

#### Option 2: Manual Download

```bash
cd ~/code/my-project
curl -sL https://github.com/YOUR_USERNAME/claude-docker-setup/archive/main.tar.gz | tar xz --strip-components=1
./setup-docker.sh
docker-compose build
docker-compose run --rm claude
```

## Usage

### Interactive Session
```bash
docker-compose run --rm claude
```

### One-off Task
```bash
docker-compose run --rm task "analyze this codebase"
```

### Custom Flags
```bash
# Without --dangerously-skip-permissions
CLAUDE_FLAGS="" docker-compose run --rm claude

# With different flags
CLAUDE_FLAGS="--verbose" docker-compose run --rm claude
```

### Manual Exploration
```bash
docker-compose run --rm bash
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

## Requirements

- macOS (M1/M2/M3)
- Docker Desktop for Mac
- Claude Code installed on host (for comparison/plugin management)

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
