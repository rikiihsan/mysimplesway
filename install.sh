```bash
#!/bin/bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$HOME/.local/share/install-logs"
LOG_FILE="$LOG_DIR/sway-install-$(date +%Y%m%d-%H%M%S).log"

mkdir -p "$LOG_DIR"

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    printf "[%s] [INFO]  %s\n" "$(date '+%F %T')" "$*" | tee -a "$LOG_FILE"
    printf "${GREEN}▶ %s${NC}\n" "$*"
}

warn() {
    printf "[%s] [WARN]  %s\n" "$(date '+%F %T')" "$*" | tee -a "$LOG_FILE"
    printf "${YELLOW}⚠ %s${NC}\n" "$*"
}

error() {
    printf "[%s] [ERROR] %s\n" "$(date '+%F %T')" "$*" | tee -a "$LOG_FILE" >&2
    printf "${RED}✖ %s${NC}\n" "$*" >&2
}

step() {
    echo
    printf "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    printf "${BLUE} %s${NC}\n" "$*"
    printf "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    echo
}

trap 'error "Installation failed at line $LINENO. Check log: $LOG_FILE"; exit 1' ERR

INSTALL_START=$(date +%s)

if [[ $EUID -eq 0 ]]; then
    echo "Do not run this script as root."
    exit 1
fi

if ! command -v pacman &>/dev/null; then
    echo "This installer must be run on Arch Linux."
    exit 1
fi

check_internet() {
    log "Checking internet connectivity..."
    if ping -c 1 archlinux.org &>/dev/null; then
        log "Internet connection OK"
    else
        error "Internet connection required"
        exit 1
    fi
}

fix_pacman_lock() {
    if [[ -f /var/lib/pacman/db.lck ]]; then
        warn "Pacman lock detected, removing..."
        sudo rm -f /var/lib/pacman/db.lck
    fi
}

enable_parallel_downloads() {
    if ! grep -q "ParallelDownloads" /etc/pacman.conf; then
        log "Enabling pacman parallel downloads"
        sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
    fi
}

optimize_mirrors() {
    log "Optimizing pacman mirrors..."
    sudo pacman -S --needed --noconfirm reflector
    sudo reflector \
        --country Singapore,Japan,South\ Korea \
        --latest 10 \
        --protocol https \
        --sort rate \
        --save /etc/pacman.d/mirrorlist
}

require_cmd() {
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            error "Missing required command: $cmd"
            exit 1
        fi
    done
}

retry() {
    local attempts=$1
    shift
    local count=0

    until "$@"; do
        count=$((count+1))
        if (( count >= attempts )); then
            error "Command failed after $attempts attempts: $*"
            return 1
        fi
        warn "Retry $count/$attempts..."
        sleep 2
    done
}

backup_config() {
    BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    for dir in sway swaylock waybar wlogout wofi kitty mako nvim qutebrowser; do
        if [[ -d "$HOME/.config/$dir" ]]; then
            log "Backing up config: $dir"
            mv "$HOME/.config/$dir" "$BACKUP_DIR/"
        fi
    done

    log "Backup directory: $BACKUP_DIR"
}

cleanup_aur() {
    rm -rf /tmp/paru-* 2>/dev/null || true
}

post_install_check() {
    log "Running post install verification"
    for cmd in sway waybar kitty; do
        if command -v "$cmd" &>/dev/null; then
            log "$cmd installed"
        else
            warn "$cmd missing"
        fi
    done
}

system_summary() {
    echo
    echo "System summary:"
    echo "---------------------------"
    echo "User: $USER"
    echo "Shell: $SHELL"
    echo "Kernel: $(uname -r)"
    echo "CPU: $(lscpu | grep 'Model name' | cut -d ':' -f2 | xargs)"
    echo "Memory: $(free -h | awk '/Mem:/ {print $2}')"
    echo "---------------------------"
}

cleanup() {
    cleanup_aur
}

trap cleanup EXIT

log "Starting Sway desktop environment installation (Arch Linux)"
log "Script dir : $SCRIPT_DIR"
log "Log file   : $LOG_FILE"

check_internet
fix_pacman_lock
enable_parallel_downloads
optimize_mirrors
require_cmd git wget unzip

log "Refreshing pacman keyring..."
sudo pacman -Sy --noconfirm archlinux-keyring

echo
echo "========================================"
echo "  Sway Desktop Installer — Arch Linux"
echo "========================================"
echo

log "Selecting browser..."
echo "Choose browser:"
select BROWSER in "qutebrowser" "brave"; do
    [[ "$BROWSER" == "qutebrowser" || "$BROWSER" == "brave" ]] && break
    echo "Invalid option, try again."
done
log "Browser selected: $BROWSER"

echo
log "Selecting Neovim profile..."
echo "Choose Neovim config:"
select NVIM_PROFILE in "max" "lite"; do
    [[ "$NVIM_PROFILE" == "max" || "$NVIM_PROFILE" == "lite" ]] && break
    echo "Invalid option, try again."
done
log "Neovim profile selected: $NVIM_PROFILE"

echo
log "Configuration selected — Browser: $BROWSER | Nvim: $NVIM_PROFILE"

log "Validating dotfiles directory..."

REQUIRED_DIRS=(sway swaylock waybar wlogout wofi kitty mako)
REQUIRED_DIRS+=("nvim/$NVIM_PROFILE")
[[ "$BROWSER" == "qutebrowser" ]] && REQUIRED_DIRS+=(qutebrowser)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ ! -d "$SCRIPT_DIR/$dir" ]]; then
        error "Dotfiles directory not found: $SCRIPT_DIR/$dir"
        exit 1
    fi
done

GREETD_CONFIG="$SCRIPT_DIR/greetd/config.toml"
if [[ ! -f "$GREETD_CONFIG" ]]; then
    error "greetd config file not found: $GREETD_CONFIG"
    exit 1
fi

log "Dotfiles validation OK"

backup_config

log "Installing core Sway & Wayland packages..."

sudo pacman -S --needed --noconfirm \
    sway swaylock swayidle swaybg \
    waybar \
    xorg-xwayland \
    kitty \
    wl-clipboard \
    brightnessctl \
    pipewire pipewire-audio pipewire-alsa pipewire-pulse wireplumber \
    noto-fonts noto-fonts-emoji ttf-fira-code \
    polkit-gnome \
    xdg-desktop-portal xdg-desktop-portal-wlr \
    wofi mako \
    wget unzip \
    ttf-font-awesome \
    git

log "Core packages installed"

if ! command -v paru &>/dev/null; then
    log "paru not found, installing..."

    sudo pacman -S --needed --noconfirm base-devel rustup
    rustup default stable

    PARU_TMP="$(mktemp -d)"
    git clone https://aur.archlinux.org/paru.git "$PARU_TMP/paru"
    pushd "$PARU_TMP/paru" >/dev/null
    makepkg -si --noconfirm
    popd >/dev/null
    rm -rf "$PARU_TMP"

    log "paru successfully installed"
else
    log "paru already available, skipping"
fi

log "Installing greetd + tuigreet + wlogout..."

paru -S --needed --noconfirm greetd greetd-tuigreet wlogout

sudo systemctl enable greetd.service
sudo systemctl set-default graphical.target

log "Installing greetd configuration..."
sudo install -Dm644 "$GREETD_CONFIG" /etc/greetd/config.toml

log "greetd ready"

log "Enabling PipeWire user services..."

for svc in pipewire.service pipewire-pulse.service wireplumber.service; do
    systemctl --user enable "$svc" 2>/dev/null \
        && log "Enabled: $svc" \
        || warn "$svc already active or not found, skipped"
done

if [[ "$BROWSER" == "brave" ]]; then
    log "Installing Brave browser..."
    paru -S --needed --noconfirm brave-bin
else
    log "Installing qutebrowser..."
    sudo pacman -S --needed --noconfirm qutebrowser
fi

log "Browser $BROWSER installed"

log "Installing user configuration files..."

mkdir -p "$HOME/.config"

for dir in sway swaylock waybar wlogout wofi kitty mako; do
    SRC="$SCRIPT_DIR/$dir"
    DST="$HOME/.config/$dir"
    log "Copying config: $dir"
    rm -rf "$DST"
    cp -r "$SRC" "$DST"
done

NVIM_SRC="$SCRIPT_DIR/nvim/$NVIM_PROFILE"
NVIM_DST="$HOME/.config/nvim"
log "Copying nvim config (profile: $NVIM_PROFILE)"
rm -rf "$NVIM_DST"
cp -r "$NVIM_SRC" "$NVIM_DST"

if [[ "$BROWSER" == "qutebrowser" ]]; then
    log "Copying config: qutebrowser"
    rm -rf "$HOME/.config/qutebrowser"
    cp -r "$SCRIPT_DIR/qutebrowser" "$HOME/.config/qutebrowser"
fi

if compgen -G "$HOME/.config/sway/scripts/*.sh" &>/dev/null; then
    chmod +x "$HOME/.config/sway/scripts/"*.sh
    log "Sway scripts set executable"
else
    warn "No sway scripts found"
fi

log "All dotfiles copied"

log "Installing FiraCode Nerd Font..."

FONT_DIR="$HOME/.local/share/fonts"
FONT_FILE="$FONT_DIR/FiraCodeNerdFont-Regular.ttf"
FIRA_VERSION="v3.1.1"

mkdir -p "$FONT_DIR"

if [[ ! -f "$FONT_FILE" ]]; then
    FONT_TMP="$(mktemp -d)"
    wget -q --show-progress \
        "https://github.com/ryanoasis/nerd-fonts/releases/download/${FIRA_VERSION}/FiraCode.zip" \
        -O "$FONT_TMP/FiraCode.zip"
    unzip -o "$FONT_TMP/FiraCode.zip" -d "$FONT_DIR"
    rm -rf "$FONT_TMP"
    fc-cache -f
    log "FiraCode Nerd Font installed"
else
    warn "FiraCode Nerd Font already exists"
fi

post_install_check

INSTALL_END=$(date +%s)
DURATION=$((INSTALL_END - INSTALL_START))

echo
echo "========================================"
echo "  Installation complete!"
echo "========================================"
echo "  Browser : $BROWSER"
echo "  Nvim    : $NVIM_PROFILE"
echo "  Log     : $LOG_FILE"
echo "  Time    : ${DURATION}s"
echo "========================================"
echo "  Reboot to enter tuigreet."
echo "========================================"
echo

system_summary

log "Installation finished — Browser: $BROWSER | Nvim: $NVIM_PROFILE"
```
