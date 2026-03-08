#!/bin/bash
# =====================================================
# Arch Linux — Sway + Tuigreet Desktop Installer
# =====================================================
# Tanggung jawab script ini:
#   - Core Wayland/Sway packages
#   - greetd + tuigreet
#   - PipeWire
#   - Browser pilihan
#   - Copy dotfiles
#   - FiraCode Nerd Font
#
# Development tools (Go, Node, PHP, dll) TIDAK termasuk.
# Kelola secara manual sesuai kebutuhan project.
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
# Logging
# -----------------------------------------------------
log()   { echo "[$(date '+%F %T')] [INFO]  $*" | tee -a "$LOG_FILE"; }
warn()  { echo "[$(date '+%F %T')] [WARN]  $*" | tee -a "$LOG_FILE"; }
error() { echo "[$(date '+%F %T')] [ERROR] $*" | tee -a "$LOG_FILE" >&2; }

trap 'error "Script gagal di baris $LINENO. Cek log: $LOG_FILE"' ERR

log "Memulai instalasi Sway desktop environment (Arch Linux)"
log "Script dir : $SCRIPT_DIR"
log "Log file   : $LOG_FILE"

# -----------------------------------------------------
# Pilihan user
# -----------------------------------------------------
echo
echo "========================================"
echo "  Sway Desktop Installer — Arch Linux"
echo "========================================"
echo

log "Memilih browser..."
echo "Pilih browser:"
select BROWSER in "qutebrowser" "brave"; do
    [[ "$BROWSER" == "qutebrowser" || "$BROWSER" == "brave" ]] && break
    echo "Pilihan tidak valid, coba lagi."
done
log "Browser dipilih: $BROWSER"

echo
log "Memilih Neovim profile..."
echo "Pilih Neovim config:"
select NVIM_PROFILE in "max" "lite"; do
    [[ "$NVIM_PROFILE" == "max" || "$NVIM_PROFILE" == "lite" ]] && break
    echo "Pilihan tidak valid, coba lagi."
done
log "Neovim profile dipilih: $NVIM_PROFILE"

echo
log "Konfigurasi dipilih — Browser: $BROWSER | Nvim: $NVIM_PROFILE"

# -----------------------------------------------------
# Validasi dotfiles tersedia
# -----------------------------------------------------
log "Memvalidasi direktori dotfiles..."

REQUIRED_DIRS=(sway swaylock waybar wlogout wofi kitty mako)
REQUIRED_DIRS+=("nvim/$NVIM_PROFILE")
[[ "$BROWSER" == "qutebrowser" ]] && REQUIRED_DIRS+=(qutebrowser)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ ! -d "$SCRIPT_DIR/$dir" ]]; then
        error "Direktori dotfiles tidak ditemukan: $SCRIPT_DIR/$dir"
        exit 1
    fi
done

GREETD_CONFIG="$SCRIPT_DIR/greetd/config.toml"
if [[ ! -f "$GREETD_CONFIG" ]]; then
    error "File greetd config tidak ditemukan: $GREETD_CONFIG"
    exit 1
fi

log "Validasi dotfiles OK"

# -----------------------------------------------------
# Core packages (pacman)
# -----------------------------------------------------
log "Menginstall core Sway & Wayland packages..."

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

log "Core packages terinstall"

# -----------------------------------------------------
# Install paru (AUR helper)
# -----------------------------------------------------
if ! command -v paru &>/dev/null; then
    log "paru tidak ditemukan, menginstall..."

    sudo pacman -S --needed --noconfirm base-devel rustup
    rustup default stable

    PARU_TMP="$(mktemp -d)"
    git clone https://aur.archlinux.org/paru.git "$PARU_TMP/paru"
    pushd "$PARU_TMP/paru" >/dev/null
    makepkg -si --noconfirm
    popd >/dev/null
    rm -rf "$PARU_TMP"

    log "paru berhasil diinstall"
else
    log "paru sudah tersedia, melewati"
fi

# -----------------------------------------------------
# greetd + tuigreet + wlogout (AUR)
# -----------------------------------------------------
log "Menginstall greetd + tuigreet + wlogout..."

paru -S --needed --noconfirm greetd greetd-tuigreet wlogout

sudo systemctl enable greetd.service
sudo systemctl set-default graphical.target

log "Menginstall konfigurasi greetd..."
sudo install -Dm644 "$GREETD_CONFIG" /etc/greetd/config.toml

log "greetd siap"

# -----------------------------------------------------
# PipeWire (user services)
# -----------------------------------------------------
log "Mengaktifkan PipeWire user services..."

for svc in pipewire.service pipewire-pulse.service wireplumber.service; do
    systemctl --user enable "$svc" 2>/dev/null \
        && log "Enabled: $svc" \
        || warn "$svc sudah aktif atau tidak ditemukan, dilewati"
done

# -----------------------------------------------------
# Browser
# -----------------------------------------------------
if [[ "$BROWSER" == "brave" ]]; then
    log "Menginstall Brave browser..."
    paru -S --needed --noconfirm brave-bin
else
    log "Menginstall qutebrowser..."
    sudo pacman -S --needed --noconfirm qutebrowser
fi

log "Browser $BROWSER terinstall"

# -----------------------------------------------------
# Copy dotfiles / user config
# -----------------------------------------------------
log "Menginstall user configuration files..."

mkdir -p "$HOME/.config"

# Sway dan config lainnya
for dir in sway swaylock waybar wlogout wofi kitty mako; do
    SRC="$SCRIPT_DIR/$dir"
    DST="$HOME/.config/$dir"
    log "Copying config: $dir"
    rm -rf "$DST"
    cp -r "$SRC" "$DST"
done

# Neovim — sesuai profile
NVIM_SRC="$SCRIPT_DIR/nvim/$NVIM_PROFILE"
NVIM_DST="$HOME/.config/nvim"
log "Copying nvim config (profile: $NVIM_PROFILE)"
rm -rf "$NVIM_DST"
cp -r "$NVIM_SRC" "$NVIM_DST"

# Qutebrowser — hanya kalau dipilih
if [[ "$BROWSER" == "qutebrowser" ]]; then
    log "Copying config: qutebrowser"
    rm -rf "$HOME/.config/qutebrowser"
    cp -r "$SCRIPT_DIR/qutebrowser" "$HOME/.config/qutebrowser"
fi

# Pastikan semua sway scripts executable
if compgen -G "$HOME/.config/sway/scripts/*.sh" &>/dev/null; then
    chmod +x "$HOME/.config/sway/scripts/"*.sh
    log "Scripts sway diberi permission executable"
else
    warn "Tidak ada .sh scripts di sway/scripts/, dilewati"
fi

log "Semua dotfiles berhasil di-copy"

# -----------------------------------------------------
# FiraCode Nerd Font
# -----------------------------------------------------
log "Menginstall FiraCode Nerd Font..."

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
    log "FiraCode Nerd Font $FIRA_VERSION terinstall"
else
    warn "FiraCode Nerd Font sudah ada, dilewati"
fi

# -----------------------------------------------------
# Selesai
# -----------------------------------------------------
echo
echo "========================================"
echo "  ✅  Instalasi selesai!"
echo "========================================"
echo "  Browser   : $BROWSER"
echo "  Nvim       : $NVIM_PROFILE"
echo "  Log        : $LOG_FILE"
echo "========================================"
echo "  Reboot untuk masuk ke tuigreet."
echo "========================================"
echo

log "Instalasi selesai — Browser: $BROWSER | Nvim: $NVIM_PROFILE"
