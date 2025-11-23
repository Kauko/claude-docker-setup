# Running Claude Code in Docker (macOS)

This Docker Compose setup runs Claude Code in a containerized environment, optimized for macOS (especially M1/M2/M3 Macs).

## Quick Start

```bash
# 1. Run the setup script (recommended)
./setup-docker.sh

# 2. Edit .env and add your API key
# Edit ANTHROPIC_API_KEY in .env file

# 3. Build the image
docker-compose build

# 4. Run Claude Code
docker-compose run --rm claude
```

### Manual Setup (Alternative)

```bash
# 1. Create the writable workspace directory
mkdir -p claude-workspace

# 2. Create .env file with your API key
echo "ANTHROPIC_API_KEY=your-key-here" > .env

# 3. Build and run
docker-compose build
docker-compose run --rm claude
```

## What's the Setup?

- ✅ **Full project access** - Claude has read-write access to your project directory at `/workspace`
- ✅ **Read-only plugins** - Your `~/.claude` directory is mounted read-only (install plugins outside container)
- ✅ **Security hardening** - Runs as your user, minimal capabilities, no privilege escalation
- ✅ **Isolated environment** - Container isolation protects your system

## Usage Examples

### Run Claude Code (default, interactive)
```bash
docker-compose run --rm claude
```

Inside the container:
- Your project is at `/workspace` (read-write, full access)
- All your skills and plugins are available from `~/.claude` (read-only)

### Run a one-off task
```bash
docker-compose run --rm task "analyze the codebase structure"
```

### Run with custom flags
```bash
# Without --dangerously-skip-permissions
CLAUDE_FLAGS="" docker-compose run --rm claude

# With specific flags
CLAUDE_FLAGS="--verbose" docker-compose run --rm claude
```

### Run with bash for exploration
```bash
docker-compose run --rm bash
```

This gives you a shell to explore the environment and test things manually.

## Directory Structure

```
/workspace/              # Your project (FULL ACCESS - read-write)
  ├── src/
  ├── tests/
  ├── README.md
  └── ...

/home/node/.claude/      # Claude's config (READ-ONLY)
  ├── plugins/
  ├── skills/
  └── settings.json
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

## Troubleshooting

### "Permission denied" errors

1. Make sure `ANTHROPIC_API_KEY` is set in `.env`:
   ```bash
   echo "ANTHROPIC_API_KEY=your-key-here" > .env
   ```

2. Run the setup script to configure everything:
   ```bash
   ./setup-docker.sh
   ```

### Skills or plugins not found

The `~/.claude` directory should be automatically mounted. Verify with:
```bash
docker-compose run --rm bash -c "ls -la /home/node/.claude/plugins"
```

### File permission issues

If you see permission errors on files in `claude-workspace/`:

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

## Advanced Features

### Environment Variables

Configure via `.env` file:

```bash
# Required
ANTHROPIC_API_KEY=your-key-here

# User/Group IDs (macOS defaults)
UID=501   # Standard macOS first user
GID=20    # Standard macOS staff group

# Claude execution flags
CLAUDE_FLAGS=--dangerously-skip-permissions

# Git configuration for commits in container
GIT_AUTHOR_NAME=Claude Code
GIT_AUTHOR_EMAIL=claude@container
```

### Security Features

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
10. **Network isolation** - Optional network restrictions can be added

### Resource Management

Default resource limits:
- CPUs: 4 cores
- Memory: 4GB limit, 512MB reservation
- Logs: 10MB max size, 3 file rotation

Adjust in `docker-compose.yml` as needed.

### Performance Optimization

This setup is optimized for macOS:

- **`:delegated` volume mounts** - Faster file sync on macOS
- **ARM64 platform** - Native M1/M2/M3 performance
- **Layer caching** - Fast rebuilds after first build
- **Minimal base image** - node:20-slim (~301MB)

## Cleanup

Remove the Docker image:
```bash
docker-compose down --rmi local
```

Remove all related containers and volumes:
```bash
docker-compose down -v --rmi all
```
