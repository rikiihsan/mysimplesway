# Neovim Configuration - Fullstack Development

Konfigurasi Neovim yang dioptimalkan untuk development Fullstack (Go, PHP, Python, React, Svelte) dengan dua varian: Lite (4GB RAM) dan Full (12GB RAM).

## Spesifikasi Target

| Versi | RAM | CPU | Fitur |
|-------|-----|-----|-------|
| Lite | 4GB | Dual Core | Essential saja |
| Full | 12GB | Quad Core | Semua fitur aktif |

**Neovim**: 0.10+
**OS**: Linux (Sway/i3 compatible)

---

## Pilih Versi Anda

### Versi Lite (4GB RAM)
- Treesitter: 12 bahasa essential
- Codeium: Virtual text disabled
- Telescope: FZF disabled
- LSP: Type checking reduced
- Plugin: Beberapa plugin berat di-disable
- Cocok untuk: Laptop lama, RAM terbatas, VM

### Versi Full (12GB RAM)
- Treesitter: 25+ bahasa
- Codeium: Virtual text enabled
- Telescope: FZF enabled
- LSP: Full type checking
- Plugin: Semua plugin aktif
- Cocok untuk: Desktop modern, RAM cukup, performa maksimal

---

## Keybindings (Sama untuk Kedua Versi)

### Copy / Paste

| Keybind | Mode | Deskripsi |
|---------|------|-----------|
| Ctrl+C | Normal | Copy satu baris ke clipboard sistem |
| Ctrl+C | Visual | Copy seleksi ke clipboard sistem |
| Ctrl+V | Normal/Visual | Paste dari clipboard sistem |
| Space+Y | Normal | Yank baris ke clipboard |
| Space+Y | Visual | Yank seleksi ke clipboard |
| Space+P | Normal/Visual | Paste dari clipboard |

---

### File Operations

| Keybind | Mode | Deskripsi |
|---------|------|-----------|
| Space+S | Normal | Save file |
| Ctrl+S | Insert | Save file (tetap di insert mode) |
| Space+Q | Normal | Quit Neovim |
| Space+Q (kapital) | Normal | Force quit semua tanpa save |

---

### Split Window

| Keybind | Mode | Deskripsi |
|---------|------|-----------|
| Space+H | Normal | Buat horizontal split (panel baru di bawah) |
| Space+V | Normal | Buat vertical split (panel baru di kanan) |
| Space+W+C | Normal | Tutup split aktif |
| Space+W+O | Normal | Tutup split lain (hanya fokus ini) |
| Alt+H | Normal | Pindah ke split kiri |
| Alt+J | Normal | Pindah ke split bawah |
| Alt+K | Normal | Pindah ke split atas |
| Alt+L | Normal | Pindah ke split kanan |
| Ctrl+Panah Atas | Normal | Resize split tambah tinggi |
| Ctrl+Panah Bawah | Normal | Resize split kurang tinggi |
| Ctrl+Panah Kiri | Normal | Resize split kurang lebar |
| Ctrl+Panah Kanan | Normal | Resize split tambah lebar |

**Catatan**: Gunakan Alt (Meta) untuk navigasi split agar tidak bentrok dengan Sway/terminal.

---

### File Explorer (NvimTree)

| Keybind | Mode | Deskripsi |
|---------|------|-----------|
| Space+E | Normal | Toggle file tree (NvimTree) |
| Space+E (kapital) | Normal | Focus ke file tree |

**Di dalam NvimTree**:
- Enter - Buka file
- a - Buat file/folder baru
- d - Delete file/folder
- r - Rename file/folder
- q - Tutup NvimTree

---

### Search & Replace (Spectre)

| Keybind | Mode | Deskripsi |
|---------|------|-----------|
| Space+S+R | Normal | Buka Spectre (search & replace seluruh project) |
| Space+S+W | Normal | Search kata di bawah cursor |
| Space+S+W | Visual | Search teks yang diseleksi |
| Space+S+F | Normal | Search dalam file aktif |

**Di dalam Spectre**:
- Enter - Replace hasil yang dipilih
- Ctrl+Enter - Replace semua
- q - Tutup Spectre

---

### Telescope (Fuzzy Finder)

| Keybind | Mode | Deskripsi |
|---------|------|-----------|
| Space+F+F | Normal | Cari file dalam project |
| Space+F+G | Normal | Live grep (cari isi file) |
| Space+F+B | Normal | Daftar buffer yang terbuka |
| Space+F+R | Normal | File yang baru dibuka (recent) |
| Space+F+W | Normal | Grep kata di bawah cursor |
| Space+F+H | Normal | Help tags |
| Space+F+D | Normal | Daftar error/warning (diagnostics) |
| Space+F+S | Normal | Document symbols |
| Space+F+S (kapital) | Normal | Workspace symbols |
| Space+F+C | Normal | Commands |
| Space+F+K | Normal | Keymaps |
| Space+F+T | Normal | Cari TODO/FIXME/HACK comments |

**Di dalam Telescope**:
- Ctrl+J / Ctrl+K - Navigasi hasil
- Enter - Buka file terpilih
- Esc / Ctrl+C - Tutup Telescope

---

### Git

| Keybind | Mode | Deskripsi |
|---------|------|-----------|
| Space+G | Normal | Buka LazyGit (Full) / Terminal lazygit (Lite) |
| Space+H+H | Normal | Toggle line blame |
| [H | Normal | Loncat ke hunk sebelumnya |
| ]H | Normal | Loncat ke hunk berikutnya |
| Space+H+S | Normal | Stage hunk |
| Space+H+R | Normal | Reset hunk |
| Space+H+P | Normal | Preview hunk |
| Space+H+B | Normal | Blame line |
| Space+H+D | Normal | Diff this |

---

### LSP (Language Server Protocol)

| Keybind | Mode | Deskripsi |
|---------|------|-----------|
| K | Normal | Hover (tampilkan info fungsi/variable) |
| Ctrl+K | Normal/Insert | Signature help (parameter fungsi) |
| G+D | Normal | Go to definition |
| G+D (kapital) | Normal | Go to declaration |
| G+R | Normal | Go to references |
| G+I | Normal | Go to implementation |
| G+T | Normal | Go to type definition |
| Space+R+N | Normal | Rename symbol |
| Space+C+A | Normal/Visual | Code action (quick fix) |
| Space+C+F | Normal | Format file |
| [D | Normal | Loncat ke error sebelumnya |
| ]D | Normal | Loncat ke error berikutnya |
| Space+D+E | Normal | Tampilkan error di float window |
| Space+D+Q | Normal | Set diagnostic to loclist |
| Space+X+X | Normal | Buka Trouble (daftar semua diagnostics) |
| Space+X+B | Normal | Trouble buffer diagnostics |
| Space+X+S | Normal | Trouble symbols |
| Space+X+L | Normal | Trouble LSP definitions |
| Space+X+Q | Normal | Trouble quickfix |

---

### AI Autocomplete (Codeium)

| Keybind | Mode | Deskripsi |
|---------|------|-----------|
| Ctrl+G | Insert | Accept saran AI |
| Ctrl+X | Insert | Dismiss saran AI |
| Alt+] | Insert | Cycle completions next |
| Alt+[ | Insert | Cycle completions prev |
| Space+A+A | Normal | Login/Auth Codeium |
| Space+A+T | Normal | Toggle Codeium on/off |

---

### Navigation

| Keybind | Mode | Deskripsi |
|---------|------|-----------|
| Esc | Normal | Clear search highlight |
| Ctrl+D | Normal | Scroll down (centered) |
| Ctrl+U | Normal | Scroll up (centered) |
| N | Normal | Next search result (centered) |
| Shift+N | Normal | Previous search result (centered) |
| G | Normal | Loncat ke akhir file (centered) |
| Space+/ | Normal | Search |
| Space+S | Normal | Replace in file |
| Space+S | Visual | Replace in selection |
| Space+S (kapital) | Normal | Replace word under cursor |
| * | Normal | Search word under cursor forward |
| # | Normal | Search word under cursor backward |

---

### Visual Mode

| Keybind | Mode | Deskripsi |
|---------|------|-----------|
| < | Visual | Indent kiri (tetap select) |
| > | Visual | Indent kanan (tetap select) |
| J | Visual | Pindah baris ke bawah |
| K | Visual | Pindah baris ke atas |
| P | Visual | Paste tanpa replace clipboard |

---

### Buffer Management

| Keybind | Mode | Deskripsi |
|---------|------|-----------|
| Space+B+D | Normal | Delete buffer aktif |
| Space+B+A | Normal | Delete semua buffer kecuali aktif |

---

### Comment

| Keybind | Mode | Deskripsi |
|---------|------|-----------|
| G+C+C | Normal | Toggle comment satu baris |
| G+C+C | Visual | Toggle comment seleksi |
| G+B+C | Normal | Toggle comment block |
| G+B+C | Visual | Toggle comment block seleksi |

---

### Flash (Enhanced Search) - Full Version Only

| Keybind | Mode | Deskripsi |
|---------|------|-----------|
| S | Normal/Visual | Flash jump |
| S (kapital) | Normal/Visual | Flash treesitter |
| R | Operator | Remote flash |
| Ctrl+S | Command | Toggle flash search |

---

### Surround - Full Version Only

| Keybind | Mode | Deskripsi |
|---------|------|-----------|
| Y+S+char | Normal/Visual | Add surround |
| D+S+char | Normal | Delete surround |
| C+S+char | Normal | Change surround |

---

## Instalasi Dependencies

### Required Tools

```bash
# Ubuntu/Debian
sudo apt install ripgrep sed git curl nodejs npm

# Arch Linux
sudo pacman -S ripgrep sed git curl nodejs npm

# Fedora
sudo dnf install ripgrep sed git curl nodejs npm
