# Kitty Discord Rich Presence

A lightweight Discord Rich Presence client for [Kitty](https://sw.kovidgoyal.net/kitty/).

It detects the active command running inside Kitty and updates your Discord Rich Presence accordingly.

## Features

- Detects multiple Kitty instances
- Detects the active Kitty window
- Remembers the last active Kitty instance
- Grace period when switching between Kitty windows/workspaces
- Command-specific Rich Presence text
- Command-specific Discord assets
- Supports SSH, Git, Docker, Python, Yazi, btop, pacman and more
- Runs as a systemd user service
- No root privileges required

## Supported Commands

| Command | Rich Presence | Asset |
|---|---|---|
| `btop` | Monitoring the system | `btop` |
| `htop` | Monitoring the system | `btop` |
| `top` | Monitoring the system | `btop` |
| `yazi` | Browsing files | `yazi` |
| `ssh` | Connected via SSH | `ssh` |
| `mosh` | Connected to a remote host | `ssh` |
| `git` | Working with Git | `git` |
| `lazygit` | Working with Git | `git` |
| `docker` | Working with containers | `docker` |
| `lazydocker` | Managing containers | `docker` |
| `podman` | Working with containers | `docker` |
| `python` | Running Python | `python` |
| `python3` | Running Python | `python` |
| `pacman` | Managing Arch Linux | `arch` |
| `paru` | Managing Arch Linux | `arch` |
| `yay` | Managing Arch Linux | `arch` |
| `systemctl` | Managing services | — |
| `journalctl` | Reading system logs | — |

When no supported application is running, the presence falls back to the terminal state.

## Requirements

- Arch Linux or another Linux distribution
- Kitty
- Python 3
- systemd user services
- A Discord desktop client
- A Discord Application

## Discord Application Setup

1. Open the Discord Developer Portal.
2. Create a new Application.
3. Give it a name such as `Kitty Terminal`.
4. Copy the application's **Application ID**.
5. Open the application's **Rich Presence → Art Assets** section.
6. Upload the PNG files from `assets/`.

Use these asset names:

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
