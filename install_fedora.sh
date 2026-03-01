#!/bin/bash
# =====================================================
# Fedora Sway + Tuigreet + Dev Environment Installer
# =====================================================

set -Eeuo pipefail

# -----------------------------------------------------
# Global variables
# -----------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$HOME/.local/share/install-logs"
LOG_FILE="$LOG_DIR/sway-install-$(date +%Y%m%d-%H%M%S).log"

mkdir -p "$LOG_DIR"

# -----------------------------------------------------
# Logging helpers
# -----------------------------------------------------
log() {
    echo "[$(date '+%F %T')] [INFO] $*" | tee -a "$LOG_FILE"
}

warn() {
    echo "[$(date '+%F %T')] [WARN] $*" | tee -a "$LOG_FILE"
}

error() {
    echo "[$(date '+%F %T')] [ERROR] $*" | tee -a "$LOG_FILE" >&2
}

trap 'error "Script failed at line $LINENO. Check log: $LOG_FILE"' ERR

log "Starting Sway developer environment installation on Fedora"
log "Script directory: $SCRIPT_DIR"
log "Log file: $LOG_FILE"

# -----------------------------------------------------
# User choices
# -----------------------------------------------------
log "Selecting browser..."
echo "Pilih browser:"
select BROWSER in "brave" "qutebrowser"; do
    [[ "$BROWSER" == "brave" || "$BROWSER" == "qutebrowser" ]] && break
    echo "Pilihan tidak valid"
done
log "Browser selected: $BROWSER"

echo
log "Selecting Neovim profile..."
echo "Pilih Neovim config:"
select NVIM_PROFILE in "max" "lite"; do
    [[ "$NVIM_PROFILE" == "max" || "$NVIM_PROFILE" == "lite" ]] && break
    echo "Pilihan tidak valid"
done
log "Neovim profile selected: $NVIM_PROFILE"

# -----------------------------------------------------
# Enable RPM Fusion
# -----------------------------------------------------
log "Enabling RPM Fusion repositories..."
sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" || \
    warn "RPM Fusion mungkin sudah terpasang"

# -----------------------------------------------------
# Core packages
# -----------------------------------------------------
log "Installing core packages..."
sudo dnf install -y \
    sway swaylock swayidle swaybg waybar xorg-x11-server-Xwayland \
    kitty wl-clipboard brightnessctl \
    pipewire pipewire-alsa pipewire-pulseaudio wireplumber \
    google-noto-fonts-common google-noto-emoji-fonts fira-code-fonts \
    mate-polkit \
    xdg-desktop-portal xdg-desktop-portal-wlr \
    wofi wget unzip fontawesome-fonts \
    mako tar

# -----------------------------------------------------
# greetd + tuigreet
# -----------------------------------------------------
log "Enabling COPR for greetd..."
sudo dnf copr enable -y reifi/greetd 2>/dev/null || true

if ! sudo dnf install -y greetd greetd-tuigreet 2>/dev/null; then
    warn "Installing greetd + tuigreet from source..."
    sudo dnf install -y cargo rust git
    TMPDIR="$(mktemp -d)"

    git clone https://git.sr.ht/~kennylevinsen/greetd "$TMPDIR/greetd"
    pushd "$TMPDIR/greetd" >/dev/null
    cargo build --release
    sudo install -Dm755 target/release/greetd /usr/local/bin/greetd
    sudo install -Dm755 target/release/agreety /usr/local/bin/agreety
    sudo install -Dm644 greetd.service /etc/systemd/system/greetd.service
    popd >/dev/null

    git clone https://github.com/apognu/tuigreet "$TMPDIR/tuigreet"
    pushd "$TMPDIR/tuigreet" >/dev/null
    cargo build --release
    sudo install -Dm755 target/release/tuigreet /usr/local/bin/tuigreet
    popd >/dev/null

    rm -rf "$TMPDIR"
fi

sudo systemctl enable greetd.service
sudo systemctl set-default graphical.target

sudo install -Dm644 "$SCRIPT_DIR/greetd/config.toml" /etc/greetd/config.toml

# -----------------------------------------------------
# PipeWire
# -----------------------------------------------------
log "Enabling PipeWire user services..."
systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service 2>/dev/null || true

# -----------------------------------------------------
# Browser
# -----------------------------------------------------
if [[ "$BROWSER" == "brave" ]]; then
    log "Installing Brave browser..."
    sudo dnf install dnf-plugins-core

    sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

    sudo dnf install brave-browser
else
    log "Installing qutebrowser..."
    sudo dnf install -y qutebrowser
fi

# -----------------------------------------------------
# User config files
# -----------------------------------------------------
log "Installing user configuration files..."
mkdir -p "$HOME/.config"

CONFIG_DIRS=(sway swaylock waybar wlogout wofi kitty mako)

[[ "$BROWSER" == "qutebrowser" ]] && CONFIG_DIRS+=(qutebrowser)
CONFIG_DIRS+=(nvim)

for dir in "${CONFIG_DIRS[@]}"; do
    if [[ "$dir" == "nvim" ]]; then
        SRC="$SCRIPT_DIR/nvim/$NVIM_PROFILE"
        DST="$HOME/.config/nvim"
    else
        SRC="$SCRIPT_DIR/$dir"
        DST="$HOME/.config/$dir"
    fi

    if [[ -d "$SRC" ]]; then
        log "Copying config: $dir"
        rm -rf "$DST"
        cp -r "$SRC" "$DST"
    else
        warn "Config directory not found: $SRC"
    fi
done

chmod +x ~/.config/sway/scripts/*.sh 2>/dev/null || true

# -----------------------------------------------------
# Development tools
# -----------------------------------------------------
log "Installing development tools..."
sudo dnf install -y \
    neovim git nodejs npm python3 python3-pip golang php composer \
    ripgrep fd-find python3-black

# Go tools
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install golang.org/x/tools/cmd/goimports@latest

# npm global
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"
npm install -g eslint_d prettier

# Composer tools
composer global require squizlabs/php_codesniffer friendsofphp/php-cs-fixer

# -----------------------------------------------------
# PATH persistence
# -----------------------------------------------------
if ! grep -q "Dev Tools PATH" "$HOME/.bashrc"; then
cat >> "$HOME/.bashrc" <<'EOF'

# ---- Dev Tools PATH ----
export PATH="$PATH:$(go env GOPATH)/bin"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.config/composer/vendor/bin:$PATH"
EOF
fi

# -----------------------------------------------------
# Nerd Font
# -----------------------------------------------------
log "Installing FiraCode Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
pushd "$FONT_DIR" >/dev/null

if [[ ! -f "FiraCodeNerdFont-Regular.ttf" ]]; then
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip
    unzip -o FiraCode.zip
    rm -f FiraCode.zip
    fc-cache -f
fi
popd >/dev/null

# -----------------------------------------------------
log "Installation completed successfully"
echo "Reboot untuk masuk ke tuigreet"
