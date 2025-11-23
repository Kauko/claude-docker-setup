#!/usr/bin/env bash
# Setup script for Claude Code Docker environment
# This script helps configure the environment for smooth operation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Claude Code Docker Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to create .env file
create_env_file() {
    local env_file=".env"
    local env_example=".env.example"

    echo -e "${BLUE}Setting up environment configuration...${NC}"

    # Create .env.example if it doesn't exist
    if [ ! -f "$env_example" ]; then
        cat > "$env_example" <<'EOF'
# Claude Code Docker Configuration for macOS
# Copy this file to .env and customize as needed

# REQUIRED: Your Anthropic API key
ANTHROPIC_API_KEY=your-api-key-here

# User/Group IDs (macOS defaults - auto-detected by setup script)
UID=501
GID=20

# Claude flags (customize as needed)
CLAUDE_FLAGS=--dangerously-skip-permissions

# Git configuration (for commits in container)
GIT_AUTHOR_NAME=Claude Code
GIT_AUTHOR_EMAIL=claude@container
GIT_COMMITTER_NAME=Claude Code
GIT_COMMITTER_EMAIL=claude@container
EOF
        echo -e "${GREEN}✓${NC} Created $env_example"
    fi

    # Create .env if it doesn't exist
    if [ ! -f "$env_file" ]; then
        cp "$env_example" "$env_file"
        echo -e "${GREEN}✓${NC} Created $env_file from example"
    else
        echo -e "${YELLOW}⚠${NC}  $env_file already exists, not overwriting"
    fi
}

# Function to check Claude Code availability (informational only - not required)
check_claude_installed() {
    echo -e "\n${BLUE}Checking Claude Code installation (optional)...${NC}"

    if command_exists claude; then
        local claude_path=$(command -v claude)
        local claude_version=$(claude --version 2>/dev/null || echo "unknown")
        echo -e "${GREEN}✓${NC} Claude Code is installed on host: $claude_path ($claude_version)"
        echo "  Note: Docker image uses its own Claude installation (v2.0.50)"
    else
        echo -e "${BLUE}ℹ${NC}  Claude Code not found on host (not required for Docker usage)"
        echo "  Docker image includes Claude Code v2.0.50"
    fi
}

# Function to set UID/GID
set_user_ids() {
    echo -e "\n${BLUE}Setting user/group IDs...${NC}"

    local current_uid=$(id -u)
    local current_gid=$(id -g)

    echo "  Current UID: $current_uid"
    echo "  Current GID: $current_gid"

    if [ -f ".env" ]; then
        sed -i.bak "s/^UID=.*/UID=$current_uid/" .env
        sed -i.bak "s/^GID=.*/GID=$current_gid/" .env
        rm -f .env.bak
        echo -e "${GREEN}✓${NC} Updated UID/GID in .env"
    fi
}

# Function to verify macOS
verify_macos() {
    echo -e "\n${BLUE}Verifying macOS environment...${NC}"

    if [[ "$(uname)" != "Darwin" ]]; then
        echo -e "${YELLOW}⚠${NC}  This setup is optimized for macOS"
        echo "  Current OS: $(uname)"
        echo "  It may still work, but defaults are set for macOS"
    else
        local arch=$(uname -m)
        echo -e "${GREEN}✓${NC} Running on macOS ($arch)"

        if [[ "$arch" == "arm64" ]]; then
            echo "  Apple Silicon (M1/M2/M3) detected"
        else
            echo "  Intel Mac detected"
        fi
    fi
}

# Function to check API key
check_api_key() {
    echo -e "\n${BLUE}Checking API key...${NC}"

    if [ -f ".env" ]; then
        if grep -q "^ANTHROPIC_API_KEY=your-api-key-here" .env || ! grep -q "^ANTHROPIC_API_KEY=.." .env; then
            echo -e "${YELLOW}⚠${NC}  API key not set in .env"
            echo "  Please edit .env and add your Anthropic API key"
            return 1
        else
            echo -e "${GREEN}✓${NC} API key appears to be set"
        fi
    fi
}


# Function to check .claude directory exists
check_claude_dir() {
    echo -e "\n${BLUE}Checking .claude directory...${NC}"

    local claude_home="$HOME/.claude"

    if [ ! -d "$claude_home" ]; then
        echo -e "${YELLOW}⚠${NC}  ~/.claude directory not found"
        echo "  This is normal if you haven't run Claude Code before"
        echo "  The directory will be created when you first run Claude"
    else
        echo -e "${GREEN}✓${NC} ~/.claude directory exists"

        # Check for plugins/skills
        if [ -d "$claude_home/plugins" ] || [ -d "$claude_home/skills" ]; then
            echo -e "${GREEN}✓${NC} Plugins/skills directory found"
        fi
    fi
}

# Function to check Docker
check_docker() {
    echo -e "\n${BLUE}Checking Docker installation...${NC}"

    if ! command_exists docker; then
        echo -e "${RED}✗${NC} Docker is not installed"
        echo "  Please install Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi

    echo -e "${GREEN}✓${NC} Docker is installed: $(docker --version)"

    if ! command_exists docker-compose && ! docker compose version >/dev/null 2>&1; then
        echo -e "${RED}✗${NC} Docker Compose is not installed"
        echo "  Please install Docker Compose"
        exit 1
    fi

    if docker compose version >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Docker Compose is installed: $(docker compose version)"
    else
        echo -e "${GREEN}✓${NC} Docker Compose is installed: $(docker-compose --version)"
    fi
}

# Main setup flow
main() {
    verify_macos
    check_docker
    create_env_file
    check_claude_installed
    set_user_ids
    check_api_key || true
    check_claude_dir

    echo
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Setup complete!${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo "Next steps:"
    echo "  1. Review and edit .env file if needed"
    echo "  2. Add your ANTHROPIC_API_KEY to .env"
    echo "  3. Build the image: docker-compose build"
    echo "  4. Run Claude Code: docker-compose run --rm claude"
    echo
    echo "For more options, see README.docker.md"
    echo
}

# Run main function
main "$@"
