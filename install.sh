#!/usr/bin/env bash
# Dotfiles install: detects Arch or Debian, installs deps, runs stow.
# --minimal: skip the desktop stack (Hyprland/Waybar/etc.) for SSH-only setups.

set -euo pipefail

MINIMAL=0
for arg in "$@"; do
  case "$arg" in
    --minimal) MINIMAL=1 ;;
    -h|--help) echo "usage: $0 [--minimal]"; exit 0 ;;
    *) echo "unknown arg: $arg" >&2; exit 1 ;;
  esac
done

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  echo "error: run as your normal user, not root (sudo is invoked per-step)" >&2
  exit 1
fi

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

# --- OS detection ---
. /etc/os-release
OS=
case "${ID:-}" in
  arch) OS=arch ;;
  debian|ubuntu|linuxmint|pop) OS=debian ;;
  *)
    case " ${ID_LIKE:-} " in
      *" arch "*) OS=arch ;;
      *" debian "*|*" ubuntu "*) OS=debian ;;
      *) echo "unsupported OS: ${ID:-unknown}" >&2; exit 1 ;;
    esac ;;
esac
log "OS=$OS minimal=$MINIMAL"

if [ "$OS" = debian ] && [ "$MINIMAL" -eq 0 ]; then
  echo "error: full install is Arch-only (Hyprland/Waybar/SDDM/etc.); pass --minimal" >&2
  exit 1
fi

# --- system packages ---
MIN_ARCH=(fish keychain tmux neovim fzf ripgrep fd git jq stow rustup curl base-devel nvimpager htop github-cli)
MIN_DEB=(fish keychain tmux neovim fzf ripgrep fd-find git jq stow curl ca-certificates build-essential htop gh)
FULL_ARCH=(hyprland hyprpaper hyprpolkitagent xdg-desktop-portal-hyprland
           waybar rofi dunst sddm uwsm dolphin kitty
           grim slurp wl-clipboard playerctl libnotify
           pipewire pipewire-pulse pipewire-alsa gst-plugin-pipewire wireplumber pamixer
           brightnessctl networkmanager bluez bluez-utils
           ttf-fira-code ttf-nerd-fonts-symbols python-pynvim)

case "$OS" in
  arch)
    pkgs=("${MIN_ARCH[@]}")
    [ "$MINIMAL" -eq 0 ] && pkgs+=("${FULL_ARCH[@]}")
    log "pacman -Syu ${pkgs[*]}"
    sudo pacman -Syu --needed --noconfirm "${pkgs[@]}"
    if ! command -v paru >/dev/null; then
      log "bootstrapping paru from AUR"
      tmp="$(mktemp -d)"
      git clone --depth 1 https://aur.archlinux.org/paru.git "$tmp/paru"
      (cd "$tmp/paru" && makepkg -si --noconfirm)
      rm -rf "$tmp"
    fi
    ;;
  debian)
    log "apt-get update && install ${MIN_DEB[*]}"
    sudo apt-get update
    sudo apt-get install -y "${MIN_DEB[@]}"
    ;;
esac

# --- rust (Debian lacks rustup in apt; Arch's rustup needs default toolchain) ---
if ! command -v rustup >/dev/null; then
  log "installing rustup via rustup.rs"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
    sh -s -- -y --default-toolchain stable --no-modify-path
fi
# shellcheck disable=SC1091
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
rustup default stable >/dev/null
rustup component add rustfmt >/dev/null

# --- nvm + node LTS ---
if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
  log "installing nvm"
  git clone --depth 1 https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
  (cd "$HOME/.nvm" \
    && git fetch --tags --depth 1 \
    && git checkout "$(git describe --abbrev=0 --tags --match 'v[0-9]*')")
fi
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"
log "nvm install --lts"
nvm install --lts --no-progress
nvm alias default 'lts/*' >/dev/null

# --- npm globals ---
log "npm i -g @anthropic-ai/claude-code claude-mermaid @fsouza/prettierd"
npm install -g @anthropic-ai/claude-code claude-mermaid @fsouza/prettierd

# --- cargo installs ---
log "cargo install tinty"
cargo install --locked tinty

# --- tpm (tmux plugin manager) ---
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  log "cloning tpm"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# --- fish as login shell ---
fish_path="$(command -v fish)"
if ! grep -qxF "$fish_path" /etc/shells; then
  log "registering $fish_path in /etc/shells"
  echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
fi
if [ "${SHELL:-}" != "$fish_path" ]; then
  log "chsh -> fish (will prompt for your password)"
  chsh -s "$fish_path"
fi

# --- stow ---
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log "stow --dotfiles -t ~ . (from $REPO_DIR)"
cd "$REPO_DIR"
stow --dotfiles -t "$HOME" .

# --- services ---
# User units are enabled via the .wants/ symlinks in dot-config/systemd/user/
# (ssh-agent on default.target; hyprpaper + waybar on graphical-session.target).
# Pick them up after stow.
log "systemctl --user daemon-reload"
systemctl --user daemon-reload

if [ "$OS" = arch ] && [ "$MINIMAL" -eq 0 ]; then
  log "enabling sddm, NetworkManager, bluetooth"
  sudo systemctl enable sddm.service NetworkManager.service bluetooth.service
fi

log "done."
log "next: open a new terminal (fish), then in tmux press prefix+I to install plugins."
[ "$MINIMAL" -eq 1 ] && log "(minimal: skipped Hyprland/Waybar/SDDM/etc.)"
[ "$OS" = arch ] && [ "$MINIMAL" -eq 0 ] && log "reboot to start sddm/networkmanager/bluetooth (or 'sudo systemctl start' them now)."
