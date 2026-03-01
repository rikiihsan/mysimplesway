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
# Enable RPM Fusion (Free & Non-Free)
# Dibutuhkan untuk beberapa codec dan driver
# -----------------------------------------------------
log "Enabling RPM Fusion repositories..."

sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" || \
    warn "RPM Fusion mungkin sudah terpasang, lanjut..."

# -----------------------------------------------------
# Core packages
# -----------------------------------------------------
log "Installing core Sway & Wayland packages..."

sudo dnf install -y \
    sway swaylock swayidle swaybg waybar xorg-x11-server-Xwayland \
    kitty wl-clipboard brightnessctl \
    pipewire pipewire-alsa pipewire-pulseaudio wireplumber \
    google-noto-fonts-common google-noto-emoji-fonts fira-code-fonts \
    polkit-gnome \
    xdg-desktop-portal xdg-desktop-portal-wlr \
    wofi wget unzip fontawesome-fonts \
    mako

# -----------------------------------------------------
# Enable Copr untuk greetd + tuigreet
# Fedora tidak menyediakan greetd di repo resmi
# -----------------------------------------------------
log "Enabling COPR repo for greetd..."
sudo dnf copr enable -y agriffis/neovim-nightly 2>/dev/null || true
sudo dnf copr enable -y reifi/greetd 2>/dev/null || \
    warn "COPR greetd tidak tersedia, coba install manual"

log "Installing greetd + tuigreet..."

# Coba install dari COPR, fallback ke build dari source jika gagal
if ! sudo dnf install -y greetd greetd-tuigreet 2>/dev/null; then
    warn "greetd tidak ditemukan di COPR, menginstall dari source..."

    sudo dnf install -y cargo rust
    TMPDIR="$(mktemp -d)"

    # Build greetd
    git clone https://git.sr.ht/~kennylevinsen/greetd "$TMPDIR/greetd"
    pushd "$TMPDIR/greetd" >/dev/null
    cargo build --release
    sudo install -Dm755 target/release/greetd /usr/local/bin/greetd
    sudo install -Dm755 target/release/agreety /usr/local/bin/agreety
    sudo install -Dm644 greetd.service /etc/systemd/system/greetd.service
    popd >/dev/null

    # Build tuigreet
    git clone https://github.com/apognu/tuigreet "$TMPDIR/tuigreet"
    pushd "$TMPDIR/tuigreet" >/dev/null
    cargo build --release
    sudo install -Dm755 target/release/tuigreet /usr/local/bin/tuigreet
    popd >/dev/null

    rm -rf "$TMPDIR"
    log "greetd + tuigreet berhasil diinstall dari source"
fi

# wlogout - install dari source jika tidak ada di repo
if ! sudo dnf install -y wlogout 2>/dev/null; then
    warn "wlogout tidak ada di repo, build dari source..."
    sudo dnf install -y meson ninja-build gtk3-devel gtk-layer-shell-devel
    TMPDIR="$(mktemp -d)"
    git clone https://github.com/ArtsyMacaw/wlogout "$TMPDIR/wlogout"
    pushd "$TMPDIR/wlogout" >/dev/null
    meson build
    ninja -C build
    sudo ninja -C build install
    popd >/dev/null
    rm -rf "$TMPDIR"
fi

# Buat user greetd jika belum ada
if ! id greeter &>/dev/null; then
    sudo useradd -M -G video greeter
fi

sudo systemctl enable greetd.service
sudo systemctl set-default graphical.target

GREETD_CONFIG_SRC="$SCRIPT_DIR/greetd/config.toml"
GREETD_CONFIG_DST="/etc/greetd/config.toml"

if [[ ! -f "$GREETD_CONFIG_SRC" ]]; then
    error "Missing greetd config: $GREETD_CONFIG_SRC"
    exit 1
fi

log "Installing greetd config..."
sudo install -Dm644 "$GREETD_CONFIG_SRC" "$GREETD_CONFIG_DST"

# -----------------------------------------------------
# PipeWire (user services)
# Di Fedora PipeWire biasanya sudah aktif,
# tapi kita pastikan tetap enabled
# -----------------------------------------------------
log "Enabling PipeWire user services..."

systemctl --user enable pipewire.service 2>/dev/null || warn "pipewire.service already enabled"
systemctl --user enable pipewire-pulse.service 2>/dev/null || warn "pipewire-pulse.service already enabled"
systemctl --user enable wireplumber.service 2>/dev/null || warn "wireplumber.service already enabled"

# -----------------------------------------------------
# Browser
# -----------------------------------------------------
log "Installing qutebrowser..."
sudo dnf install -y qutebrowser

# -----------------------------------------------------
# User config files
# -----------------------------------------------------
log "Installing user configuration files..."

mkdir -p "$HOME/.config"

for dir in nvim sway swaylock waybar wlogout wofi kitty mako qutebrowser; do
    SRC="$SCRIPT_DIR/$dir"
    DST="$HOME/.config/$dir"

    if [[ -d "$SRC" ]]; then
        log "Copying config: $dir"
        rm -rf "$DST"
        cp -r "$SRC" "$DST"
    else
        warn "Config directory not found: $SRC (skipped)"
    fi
done

log "Enable screenshot and screenrecord scripts..."
chmod +x ~/.config/sway/scripts/screenrecord.sh
chmod +x ~/.config/sway/scripts/screenshoot.sh

# -----------------------------------------------------
# Development stack
# -----------------------------------------------------
log "Installing development tools..."

sudo dnf install -y \
    neovim git nodejs npm python3 python3-pip golang php composer \
    ripgrep fd-find lazygit python3-black

# Go tools
log "Installing Go tools..."
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install golang.org/x/tools/cmd/goimports@latest

# npm global (user-local)
log "Configuring npm global directory..."
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"
npm install -g eslint_d prettier

# Composer global tools
log "Installing Composer tools..."
composer global require squizlabs/php_codesniffer
composer global require friendsofphp/php-cs-fixer

# -----------------------------------------------------
# Persist PATH
# -----------------------------------------------------
log "Updating PATH in ~/.bashrc..."

if ! grep -q "Dev Tools PATH" "$HOME/.bashrc" 2>/dev/null; then
    {
        echo ''
        echo '# ---- Dev Tools PATH ----'
        echo 'export PATH="$PATH:$(go env GOPATH)/bin"'
        echo 'export PATH="$HOME/.npm-global/bin:$PATH"'
        echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"'
    } >> "$HOME/.bashrc"
else
    warn "PATH block already exists in ~/.bashrc"
fi

# -----------------------------------------------------
# Nerd Font (FiraCode)
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
    log "FiraCode Nerd Font installed"
else
    warn "FiraCode Nerd Font already present"
fi

popd >/dev/null

# -----------------------------------------------------
# SELinux note (Fedora-specific)
# -----------------------------------------------------
log "Catatan SELinux:"
warn "Fedora menggunakan SELinux (Enforcing by default)."
warn "Jika greetd atau sway tidak bisa jalan, cek: sudo ausearch -m avc -ts recent"
warn "Atau set sementara ke permissive: sudo setenforce 0 (tidak disarankan untuk produksi)"

# -----------------------------------------------------
log "Installation completed successfully"
log "Reboot to start tuigreet login"
echo
echo "✅ Sway minimal developer setup untuk Fedora selesai"
echo "📄 Log saved to: $LOG_FILE"
echo
echo "⚠️  Catatan penting untuk Fedora:"
echo "   - Jika greetd tidak tersedia di COPR, script akan build dari source (butuh waktu)"
echo "   - SELinux bisa menyebabkan masalah — periksa log dengan: sudo ausearch -m avc -ts recent"
echo "   - Reboot sekarang untuk masuk ke tuigreet"
