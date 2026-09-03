#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$HOME/.local/share/kitty-discord-rpc"
BIN="$HOME/.local/bin/kitty-discord-rpc"
SERVICE="$HOME/.config/systemd/user/kitty-discord-rpc.service"
ENV_DIR="$HOME/.config/kitty-discord-rpc"

echo "==> Uninstalling Kitty Discord Rich Presence"

systemctl --user disable --now kitty-discord-rpc.service 2>/dev/null || true

rm -f "$SERVICE"
rm -f "$BIN"

systemctl --user daemon-reload

rm -rf "$APP_DIR"

echo
echo "Kitty Discord Rich Presence has been removed."
echo
echo "Your configuration was kept at:"
echo "  $ENV_DIR"
echo
echo "Your Kitty listen_on configuration was also left untouched."
EOF

chmod +x uninstall.sh
