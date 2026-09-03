# Kitty Discord Rich Presence

A lightweight Discord Rich Presence client for [Kitty](https://sw.kovidgoyal.net/kitty/).

It detects the active command running inside Kitty and updates your Discord Rich Presence accordingly.

## Features

* Detects multiple Kitty instances
* Detects the active Kitty window
* Remembers the last active Kitty instance
* Grace period when switching between Kitty windows or workspaces
* Command-specific Rich Presence text
* Command-specific Discord assets
* Supports SSH, Git, Docker, Python, Yazi, btop, pacman, and more
* Runs as a systemd user service
* No root privileges required
* Lightweight Python implementation

## Supported Commands

| Command      | Rich Presence              | Asset    |
| ------------ | -------------------------- | -------- |
| `btop`       | Monitoring the system      | `btop`   |
| `htop`       | Monitoring the system      | `btop`   |
| `top`        | Monitoring the system      | `btop`   |
| `yazi`       | Browsing files             | `yazi`   |
| `ssh`        | Connected via SSH          | `ssh`    |
| `mosh`       | Connected to a remote host | `ssh`    |
| `git`        | Working with Git           | `git`    |
| `lazygit`    | Working with Git           | `git`    |
| `docker`     | Working with containers    | `docker` |
| `lazydocker` | Managing containers        | `docker` |
| `podman`     | Working with containers    | `docker` |
| `python`     | Running Python             | `python` |
| `python3`    | Running Python             | `python` |
| `pacman`     | Managing Arch Linux        | `arch`   |
| `paru`       | Managing Arch Linux        | `arch`   |
| `yay`        | Managing Arch Linux        | `arch`   |
| `systemctl`  | Managing services          | —        |
| `journalctl` | Reading system logs        | —        |

When no supported application is running, the Rich Presence falls back to the terminal state.

## Requirements

* Linux
* Kitty
* Python 3
* systemd user services
* Discord desktop client
* A Discord Application

The project is primarily developed and tested on Arch Linux.

## Discord Application Setup

Create a Discord Application before installing the Rich Presence client.

1. Open the Discord Developer Portal.
2. Create a new Application.
3. Give it a name such as `Kitty Terminal`.
4. Copy the application's **Application ID**.
5. Open **Rich Presence → Art Assets**.
6. Upload the PNG files from the `assets/` directory.

The following asset keys are used by the application:

```text
kitty
terminal
btop
yazi
ssh
git
arch
python
docker
```

Make sure the asset names match these keys.

The `kitty` asset is used as the small Rich Presence image, while command-specific assets are used as the large image.

## Installation

Clone the repository:

```bash
git clone https://github.com/Kisaragilice/kitty-discord-rpc-proper
cd kitty-discord-rpc
```

Make the installer executable if necessary:

```bash
chmod +x install.sh
```

Run the installer:

```bash
./install.sh
```

The installer will:

* Check required dependencies
* Create a Python virtual environment
* Install `pypresence`
* Install the Rich Presence client
* Install the systemd user service
* Create the local configuration directory
* Create the local environment file
* Configure Kitty remote control
* Reload the systemd user manager

No `sudo` is required.

## Configuration

After installation, open:

```text
~/.config/kitty-discord-rpc/env
```

Set your Discord Application ID:

```text
KITTY_RPC_CLIENT_ID=YOUR_DISCORD_APPLICATION_ID
```

Additional settings:

```text
KITTY_RPC_POLL=2
KITTY_RPC_DEBUG=0
KITTY_RPC_GRACE_SECONDS=10
KITTY_RPC_SOCKET_GLOB=/tmp/kitty-rpc-*
```

### Configuration Options

| Variable                  |            Default | Description                                                |
| ------------------------- | -----------------: | ---------------------------------------------------------- |
| `KITTY_RPC_CLIENT_ID`     |                  — | Discord Application ID                                     |
| `KITTY_RPC_POLL`          |                `2` | Polling interval in seconds                                |
| `KITTY_RPC_DEBUG`         |                `0` | Enables debug logging when set to `1`                      |
| `KITTY_RPC_GRACE_SECONDS` |               `10` | How long the last Kitty remains active after focus is lost |
| `KITTY_RPC_SOCKET_GLOB`   | `/tmp/kitty-rpc-*` | Pattern used to discover Kitty sockets                     |

**Never commit your `env` file to Git.**

The repository includes `.env.example` as a safe configuration template.

## Start the Service

After configuring your Discord Application ID:

```bash
systemctl --user enable --now kitty-discord-rpc
```

Check the service:

```bash
systemctl --user status kitty-discord-rpc --no-pager
```

The service should show:

```text
Active: active (running)
```

The service runs as your normal user and starts automatically with your user session.

## Rich Presence Detection

The application checks the active Kitty windows and determines which command is currently running.

For example:

```text
btop
```

will produce:

```text
Monitoring the system
```

with the `btop` asset.

Running:

```text
yazi
```

will produce:

```text
Browsing files
```

with the `yazi` asset.

Running:

```text
ssh user@server
```

will produce:

```text
Connected via SSH
```

with the `ssh` asset.

## Multiple Kitty Instances

The application supports multiple Kitty instances.

Kitty sockets are discovered using:

```text
/tmp/kitty-rpc-*
```

For example:

```text
/tmp/kitty-rpc-10213
/tmp/kitty-rpc-12254
/tmp/kitty-rpc-30879
```

The application scans these sockets automatically and attempts to determine the currently focused Kitty instance.

You do not need to manually specify which Kitty instance should be used.

## Remember Last Kitty

When focus temporarily moves away from Kitty, the application remembers the previously active Kitty instance.

The last selected Kitty is stored at:

```text
~/.local/state/kitty-discord-rpc/last-kitty.json
```

This prevents the Rich Presence from disappearing immediately when switching workspaces or temporarily moving focus away from Kitty.

The default grace period is:

```text
KITTY_RPC_GRACE_SECONDS=10
```

You can increase or decrease it depending on your workflow.

For example:

```text
KITTY_RPC_GRACE_SECONDS=15
```

## Kitty Remote Control

The application communicates with Kitty using Kitty's remote-control interface.

The installer automatically adds:

```text
listen_on unix:/tmp/kitty-rpc-{kitty_pid}
```

to:

```text
~/.config/kitty/kitty.conf
```

Each Kitty instance then creates a socket similar to:

```text
/tmp/kitty-rpc-30879
```

The application automatically discovers these sockets.

### Important

Do not manually pass the wildcard to Kitty:

```bash
kitty @ --to "unix:/tmp/kitty-rpc-*" ls
```

That does not work because Kitty expects a specific socket path.

For example, a concrete socket can be queried with:

```bash
kitty @ --to "unix:/tmp/kitty-rpc-30879" ls
```

The wildcard is handled internally by `kitty-discord-rpc`.

## Debugging

If the Rich Presence is not updating correctly, enable debug logging.

Edit:

```text
~/.config/kitty-discord-rpc/env
```

and change:

```text
KITTY_RPC_DEBUG=0
```

to:

```text
KITTY_RPC_DEBUG=1
```

Restart the service:

```bash
systemctl --user restart kitty-discord-rpc
```

Then follow the logs:

```bash
journalctl --user -u kitty-discord-rpc -f
```

Debug output can show information such as:

```text
using remembered Kitty: /tmp/kitty-rpc-30879
focused Kitty selected: /tmp/kitty-rpc-30879
```

This is useful when troubleshooting multiple Kitty instances or workspace switching.

## Checking Kitty Sockets

To see the currently available Kitty sockets:

```bash
ls -la /tmp/kitty-rpc-*
```

If no sockets exist, make sure Kitty contains:

```text
listen_on unix:/tmp/kitty-rpc-{kitty_pid}
```

in:

```text
~/.config/kitty/kitty.conf
```

Restart Kitty after changing its configuration.

## Troubleshooting

### Discord Rich Presence is not showing

Check the service:

```bash
systemctl --user status kitty-discord-rpc --no-pager
```

Then check the logs:

```bash
journalctl --user -u kitty-discord-rpc -n 100 --no-pager
```

Make sure:

* Discord desktop is running
* Your Discord Application ID is correct
* The application assets have been uploaded
* Kitty is running
* Kitty remote control is enabled
* Kitty sockets exist under `/tmp/kitty-rpc-*`

### Service fails to start

Check:

```bash
systemctl --user status kitty-discord-rpc --no-pager
```

and:

```bash
journalctl --user -u kitty-discord-rpc -n 100 --no-pager
```

Also verify that the environment file exists:

```bash
ls -l ~/.config/kitty-discord-rpc/env
```

### `KITTY_RPC_CLIENT_ID` is missing

Open:

```text
~/.config/kitty-discord-rpc/env
```

and make sure it contains:

```text
KITTY_RPC_CLIENT_ID=YOUR_DISCORD_APPLICATION_ID
```

Then restart:

```bash
systemctl --user restart kitty-discord-rpc
```

### Kitty sockets are missing

Check:

```bash
ls -la /tmp/kitty-rpc-*
```

If nothing is returned, check your Kitty configuration:

```bash
grep -n "listen_on" ~/.config/kitty/kitty.conf
```

You should have:

```text
listen_on unix:/tmp/kitty-rpc-{kitty_pid}
```

Restart Kitty after modifying `kitty.conf`.

## Uninstallation

Run:

```bash
./uninstall.sh
```

The uninstall script removes:

* Installed Rich Presence client
* Python virtual environment
* systemd user service

Your local configuration is intentionally kept at:

```text
~/.config/kitty-discord-rpc/
```

The Kitty `listen_on` configuration is also left untouched.

This allows you to reinstall the application later without losing your local configuration.

## Project Structure

```text
kitty-discord-rpc/
├── assets/
│   ├── arch.png
│   ├── btop.png
│   ├── docker.png
│   ├── git.png
│   ├── kitty.png
│   ├── python.png
│   ├── ssh.png
│   ├── terminal.png
│   └── yazi.png
├── kitty-discord-rpc
├── kitty-discord-rpc.service
├── install.sh
├── uninstall.sh
├── .env.example
├── .gitignore
├── LICENSE
└── README.md
```

## Security

The Discord Application ID is stored locally in:

```text
~/.config/kitty-discord-rpc/env
```

It is not included in the systemd service file.

The repository's `.gitignore` prevents local environment files from being committed.

Never publish your private configuration file if it contains credentials or other sensitive information.

## License

MIT License.

See [`LICENSE`](LICENSE) for the full license text.
