# Claude Code Docker Setup

A production-ready Docker setup for running Claude Code in a containerized environment, optimized for macOS (especially M1/M2/M3 Macs).

## Features

- ✅ **Full project access** - Claude has read-write access to your project
- ✅ **Read-only plugins** - Your `~/.claude` config is mounted read-only
- ✅ **M1 optimized** - Native ARM64 platform, `:delegated` volume mounts
- ✅ **Secure** - Container isolation, user mapping, resource limits
- ✅ **Self-contained** - Claude Code v2.0.50 installed in image

## Quick Start

### Option 1: Git Submodule (Recommended)

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

### Option 2: Manual Download

If you prefer not to use git submodules, download files directly:

```bash
cd ~/code/my-project
curl -sL https://github.com/Kauko/claude-docker-setup/archive/main.tar.gz | \
  tar xz --strip-components=1 claude-docker-setup-main/{Dockerfile,docker-compose.yml,.dockerignore,setup-docker.sh,.env.example}
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
```

## Usage

### Interactive Session
```bash
# With submodule
docker-compose -f .docker/docker-compose.yml run --rm claude

# With manual download (files in root)
docker-compose run --rm claude
```

Inside the container:
- Your project is at `/workspace` (read-write, full access)
- All your skills and plugins are available from `~/.claude` (read-only)

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

This gives you a shell to explore the environment and test things manually.

## Configuration

The `.env` file (created by setup script):

```bash
# Required
ANTHROPIC_API_KEY=your-key-here

# User/Group IDs (macOS defaults - auto-detected)
UID=501
GID=20

# Claude flags
CLAUDE_FLAGS=--dangerously-skip-permissions

# Git configuration for commits in container
GIT_AUTHOR_NAME=Claude Code
GIT_AUTHOR_EMAIL=claude@container
```

## Directory Structure

```
/workspace          → Your project directory (read-write)
/home/node/.claude  → Your ~/.claude config (read-only)
```

**Note:**
- Your project directory has full read-write access - Claude can create, modify, and delete files
- `~/.claude` is read-only - install/update plugins by running Claude outside the container

## Testing the Setup

To verify the container works correctly:

```bash
docker-compose run --rm bash

# Inside the container:
# Check Claude works
claude --version

# Check you can read/write to your project
ls /workspace
echo "test" > /workspace/test.txt
rm /workspace/test.txt

# Check plugins are accessible (read-only)
ls /home/node/.claude/plugins
```

## Customization

### Allow writing to specific directories

Edit `docker-compose.yml` and add writable mounts to `x-volume-defaults`:

```yaml
x-volume-defaults: &volume-defaults
  # ... existing mounts ...
  - ./output:/workspace/output:rw  # Allow writes to output/
```

### Adjust resource limits

Edit the `deploy.resources` section in `docker-compose.yml`:

```yaml
deploy:
  resources:
    limits:
      cpus: '8'      # Increase CPU limit
      memory: 8G     # Increase memory limit
```

### Adjust security settings

If Claude needs additional permissions, modify the `cap_add` section in `docker-compose.yml` under `x-security-defaults`.

## Security Features

This setup includes multiple security layers:

1. **Container isolation** - Processes isolated from host system
2. **User mapping** - Runs as your UID/GID, not root
3. **Minimal capabilities** - Drops all Linux capabilities, adds only essentials
4. **No privilege escalation** - `no-new-privileges` security option
5. **Tmpfs for /tmp** - Prevents persistent malware
6. **Resource limits** - CPU and memory constraints (4 cores, 4GB RAM)
7. **Init system (tini)** - Proper signal handling and zombie process reaping
8. **Health checks** - Monitors container health
9. **Read-only plugins** - Prevents accidental plugin modification

## Performance Optimization

This setup is optimized for macOS:

- **`:delegated` volume mounts** - Faster file sync on macOS
- **ARM64 platform** - Native M1/M2/M3 performance
- **Layer caching** - Fast rebuilds after first build
- **Minimal base image** - node:20-slim (~301MB)

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
  tar xz --strip-components=1 claude-docker-setup-main/{Dockerfile,docker-compose.yml,.dockerignore,setup-docker.sh,.env.example}
mv .env.backup .env
docker-compose build --no-cache
```

## Troubleshooting

### Permission Issues
Run `./setup-docker.sh` to auto-detect your UID/GID.

### API Key Not Set
Add `ANTHROPIC_API_KEY=your-key` to `.env` file.

### Skills or plugins not found
The `~/.claude` directory should be automatically mounted. Verify with:
```bash
docker-compose run --rm bash -c "ls -la /home/node/.claude/plugins"
```

### File permission issues
If you see permission errors on files:

1. Check your UID/GID are set in `.env`:
   ```bash
   echo "UID=$(id -u)" >> .env
   echo "GID=$(id -g)" >> .env
   ```

2. Or run the setup script which does this automatically:
   ```bash
   ./setup-docker.sh
   ```

### Claude version mismatch
The Docker image includes Claude Code v2.0.50. To use a different version, update the `Dockerfile`:

```dockerfile
RUN npm install -g @anthropic-ai/claude-code@VERSION
```

Then rebuild:
```bash
docker-compose build --no-cache claude
```

### Slow performance on macOS
Volume mounts can be slow on macOS. The setup already includes `:delegated` flag for better performance, but for large projects consider:

1. Limiting the scope of mounted directories
2. Using Docker Desktop's VirtioFS (enabled by default in newer versions)

### Need to rebuild the image
After updating Dockerfile:
```bash
docker-compose build --no-cache claude
```

### Health check failing
If the health check shows as unhealthy:
```bash
docker-compose ps
```

Check that Claude binary is accessible:
```bash
docker-compose run --rm bash -c "claude --version"
```

## Cleanup

Remove the Docker image:
```bash
docker-compose down --rmi local
```

Remove all related containers and volumes:
```bash
docker-compose down -v --rmi all
```

## Requirements

- macOS (M1/M2/M3 recommended, Intel supported)
- Docker Desktop for Mac
- Claude Code installed on host (for plugin management)
- Git (for submodule approach)

## Files Included

- `Dockerfile` - Node 20.18.1 + Claude Code 2.0.50
- `docker-compose.yml` - Service definitions (claude, bash, task)
- `.dockerignore` - Build context exclusions
- `setup-docker.sh` - Auto-configuration script
- `.env.example` - Configuration template

## License

MIT License - see [LICENSE](LICENSE) file for details.
