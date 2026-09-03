#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$HOME/.local/share/kitty-discord-rpc"
VENV="$APP_DIR/venv"
BIN="$HOME/.local/bin/kitty-discord-rpc"
SERVICE="$HOME/.config/systemd/user/kitty-discord-rpc.service"
ENV_DIR="$HOME/.config/kitty-discord-rpc"
ENV_FILE="$ENV_DIR/env"
KITTY_CONF="$HOME/.config/kitty/kitty.conf"

echo "==> Installing Kitty Discord Rich Presence"

# Required commands
for cmd in python kitty kitten systemctl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: '$cmd' is required but was not found."
        exit 1
    fi
done

mkdir -p \
    "$APP_DIR" \
    "$HOME/.local/bin" \
    "$HOME/.config/systemd/user" \
    "$ENV_DIR"

# Python virtual environment
if [[ ! -x "$VENV/bin/python" ]]; then
    echo "==> Creating Python virtual environment"
    python -m venv "$VENV"
fi

echo "==> Installing Python dependencies"
"$VENV/bin/python" -m pip install --upgrade pip pypresence

# Install application
echo "==> Installing application"
install -m 755 kitty-discord-rpc "$BIN"

# Install systemd service
echo "==> Installing systemd user service"
install -m 644 kitty-discord-rpc.service "$SERVICE"

# Create environment file without overwriting existing configuration
if [[ ! -f "$ENV_FILE" ]]; then
    echo "==> Creating environment file"
    cat > "$ENV_FILE" <<'ENVEOF'
# Discord Application ID
KITTY_RPC_CLIENT_ID=

# Poll interval in seconds
KITTY_RPC_POLL=2

# Set to 1 for debug logging
KITTY_RPC_DEBUG=0

# How long the last Kitty remains active after focus is lost
KITTY_RPC_GRACE_SECONDS=10

# Kitty remote-control socket pattern
KITTY_RPC_SOCKET_GLOB=/tmp/kitty-rpc-*
ENVEOF
    chmod 600 "$ENV_FILE"
else
    echo "==> Existing environment file found; keeping it"
fi

# Ensure Kitty remote control is enabled
mkdir -p "$(dirname "$KITTY_CONF")"

if [[ ! -f "$KITTY_CONF" ]]; then
    touch "$KITTY_CONF"
fi

if ! grep -Fq 'listen_on unix:/tmp/kitty-rpc-{kitty_pid}' "$KITTY_CONF"; then
    echo "==> Enabling Kitty remote control"
    printf '\n# Kitty Discord Rich Presence\nlisten_on unix:/tmp/kitty-rpc-{kitty_pid}\n' >> "$KITTY_CONF"
else
    echo "==> Kitty remote control already configured"
fi

# Reload systemd
echo "==> Reloading systemd"
systemctl --user daemon-reload

echo
echo "Installation complete."
echo
echo "Edit your Discord Application ID:"
echo
echo "  $ENV_FILE"
echo
echo "Then start the service:"
echo
echo "  systemctl --user enable --now kitty-discord-rpc"
echo
echo "Check status:"
echo
echo "  systemctl --user status kitty-discord-rpc --no-pager"
echo
echo "View logs:"
echo
echo "  journalctl --user -u kitty-discord-rpc -f"
echo
EOF

chmod +x install.sh
