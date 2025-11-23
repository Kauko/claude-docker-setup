FROM node:20.18.1-slim

# Install git and tini (init system for proper process management)
# Clean up in same layer to reduce image size
RUN apt-get update && \
    apt-get install -y --no-install-recommends git tini && \
    rm -rf /var/lib/apt/lists/*

# Install Claude Code globally
# Pin to specific version for reproducible builds
RUN npm install -g @anthropic-ai/claude-code@2.0.50

WORKDIR /workspace

# Run as non-root user (node user is provided by base image)
USER node

# Use tini as init system to handle signals and reap zombie processes
ENTRYPOINT ["/usr/bin/tini", "--"]

# Default: run without flags, but can be overridden via docker-compose or CLI
CMD ["claude"]
