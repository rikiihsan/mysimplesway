-- ==================== NEOVIM CONFIG — 4GB RAM / Celeron N4020 ====================
-- CPU : Intel Celeron N4020 — 2c2t, single-core lemah, hindari background thread
-- RAM : 4GB — agresif hemat memori, lazy load semua plugin
-- Stack: Go + SvelteKit/TypeScript
-- Codeium: Dipertahankan (ghost text, tanpa chat UI)
-- Prioritas: RAM rendah → Responsif saat ngetik → Fitur lengkap → Startup cepat
--
-- Changelog vs config 12GB:
--   - LSP dikurangi: hanya gopls, ts_ls, svelte, tailwindcss, html, cssls, lua_ls
--   - Python (pyright) & PHP (intelephense) dibuang
--   - Treesitter: parser dikurangi ke bahasa yang dipakai saja
--   - nvim-cmp: debounce lebih tinggi, max_view_entries lebih kecil
--   - bufferline: dibuang → pakai lualine saja (hemat render)
--   - nvim-spectre: dibuang → pakai built-in :grep / telescope live_grep
--   - indent-blankline: minimal mode
--   - updatetime: 300ms (lebih hemat CPU vs 100ms)
--   - signcolumn: "yes:1" (fix lebar kolom, tidak resize-resize)
--   - Treesitter highlight: tetap aktif tapi parser minimal

-- ==================== LEADER KEY ====================
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- ==================== PERFORMANCE SETTINGS ====================
-- N4020 punya IPC rendah — updatetime jangan terlalu kecil
vim.opt.updatetime  = 300          -- CursorHold delay (ms); 300 lebih hemat CPU dari 100
vim.opt.timeoutlen  = 400
-- lazyredraw: JANGAN diaktifkan di Neovim modern (bikin glitch)
vim.opt.ttyfast     = true
vim.opt.synmaxcol   = 200          -- Turun dari 300 → 200 (hemat render baris panjang)
vim.opt.regexpengine = 1

-- ==================== UI SETTINGS ====================
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.signcolumn     = "yes:1"   -- Fix lebar 1 kolom, tidak melebar-menyempit
vim.opt.cursorline     = true
vim.opt.scrolloff      = 6         -- Turun dari 8 → 6
vim.opt.sidescrolloff  = 6
vim.opt.colorcolumn    = "100"     -- Satu ruler cukup, hemat render
vim.opt.cmdheight      = 1
vim.opt.showmode       = false
vim.opt.termguicolors  = true
vim.opt.pumheight      = 10        -- Turun dari 15 → 10 (popup lebih ringkas)

-- ==================== EDITING ====================
vim.opt.expandtab    = true
vim.opt.shiftwidth   = 2           -- Default 2 (JS/Svelte standar)
vim.opt.tabstop      = 2
vim.opt.softtabstop  = 2
vim.opt.smartindent  = true
vim.opt.wrap         = false
vim.opt.linebreak    = true

-- ==================== SEARCH ====================
vim.opt.ignorecase = true
vim.opt.smartcase  = true
vim.opt.hlsearch   = true
vim.opt.incsearch  = true

-- ==================== SYSTEM ====================
vim.opt.clipboard   = "unnamedplus"
vim.opt.undofile    = true
vim.opt.undolevels  = 5000         -- Turun dari 10000 → 5000 (hemat RAM)
vim.opt.swapfile    = false
vim.opt.backup      = false
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- ==================== SPLITS ====================
vim.opt.splitright = true
vim.opt.splitbelow = true

-- ==================== COMPLETION ====================
vim.opt.completeopt = "menu,menuone,noselect"

-- ==================== FOLDING ====================
-- Treesitter fold tetap aktif, tapi foldlevel tinggi agar tidak auto-fold
vim.opt.foldmethod = "expr"
vim.opt.foldexpr   = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel  = 99

-- ==================== PLUGIN MANAGER (lazy.nvim) ====================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==================== PLUGINS ====================
require("lazy").setup({

  -- ── LSP Core ──────────────────────────────────────────────────────────────
  -- Lazy load: hanya aktif saat buka file, bukan saat startup
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      -- fidget: indikator loading LSP di pojok kanan bawah (ringan)
      { "j-hui/fidget.nvim", opts = { notification = { window = { winblend = 0 } } } },
      -- neodev: autocomplete untuk Neovim Lua API (hanya aktif di .lua)
      { "folke/neodev.nvim", opts = {} },
    },
  },

  -- ── Formatter ─────────────────────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd   = "ConformInfo",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          go                = { "gofmt", "goimports" },
          javascript        = { "prettier" },
          typescript        = { "prettier" },
          javascriptreact   = { "prettier" },
          typescriptreact   = { "prettier" },
          svelte            = { "prettier" },
          html              = { "prettier" },
          css               = { "prettier" },
          json              = { "prettier" },
          markdown          = { "prettier" },
        },
        format_on_save = {
          timeout_ms   = 1500,   -- Sedikit lebih longgar untuk N4020
          lsp_fallback = true,
        },
      })
    end,
  },

  -- ── AI Autocomplete: Codeium ──────────────────────────────────────────────
  -- Ghost text AI — login dengan :Codeium Auth
  -- Tips hemat resource: Codeium jalan di server cloud, bukan lokal
  -- jadi tidak membebani CPU/RAM mesin kamu
  {
    "Exafunction/codeium.nvim",
    event = "InsertEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({
        enable_chat = false,  -- Matikan chat UI, hemat resource
      })
    end,
  },

  -- ── Autocompletion ────────────────────────────────────────────────────────
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "Exafunction/codeium.nvim",
    },
  },

  -- ── Fuzzy Finder ──────────────────────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          prompt_prefix   = " > ",
          selection_caret = " ",
          -- Layout lebih kecil → render lebih cepat di layar kecil/lambat
          layout_config   = { height = 0.80, width = 0.80 },
          file_ignore_patterns = {
            "node_modules", ".git/", "vendor/", "%.lock",
            "__pycache__", "%.pyc", "dist/", "build/", ".svelte%-kit/",
          },
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading",
            "--with-filename", "--line-number", "--column",
            "--smart-case", "--hidden",
            "--glob=!.git/",
            "--glob=!node_modules/",
            "--glob=!.svelte-kit/",
            "--glob=!build/",
          },
        },
        pickers = {
          find_files = { hidden = true },
        },
      })
      telescope.load_extension("fzf")
    end,
  },

  -- ── File Explorer ─────────────────────────────────────────────────────────
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      vim.g.loaded_netrw       = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup({
        view = { width = 30 },   -- Sedikit lebih sempit dari 32
        renderer = {
          root_folder_label = ":~:s?$?/..?",
          icons = {
            show = { git = true, folder = true, file = true },
            glyphs = {
              default = "",
              symlink = "",
              folder = {
                default = "", open = "", empty = "",
                empty_open = "", symlink = "",
              },
              git = {
                unstaged = "✗", staged = "✓", unmerged = "",
                renamed = "➜", untracked = "★", deleted = "",
              },
            },
          },
          highlight_git = true,
        },
        filters        = { dotfiles = false, custom = { "^.git$", "^.svelte%-kit$" } },
        git            = { enable = true },
        update_focused_file = { enable = true },
        actions = {
          open_file = { quit_on_open = false },
        },
      })
    end,
  },

  -- ── Treesitter ────────────────────────────────────────────────────────────
  -- Parser dikurangi drastis → hanya bahasa yang dipakai
  -- Ini penghematan RAM & waktu parse yang signifikan
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        -- ❌ Hanya install parser yang benar-benar dipakai
        -- Tidak ada Python, PHP, SQL, dockerfile, dll
        ensure_installed = {
          "go",
          "javascript", "typescript", "tsx", "svelte",
          "html", "css",
          "json", "yaml",
          "markdown", "markdown_inline",
          "bash", "lua", "vim", "vimdoc",
          "gitcommit",
        },
        sync_install  = false,
        auto_install  = false,   -- ❌ Matikan auto install — hemat bandwidth & disk I/O
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        textobjects = {
          select = {
            enable    = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
            },
            goto_prev_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
            },
          },
        },
      })
    end,
  },

  -- ── Git ───────────────────────────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "▁" },
          topdelete    = { text = "▔" },
          changedelete = { text = "▎" },
        },
        current_line_blame      = false,
        current_line_blame_opts = { delay = 800 },  -- Delay lebih panjang, hemat CPU
        on_attach = function(bufnr)
          local gs   = package.loaded.gitsigns
          local opts = { buffer = bufnr }
          vim.keymap.set("n", "]h", gs.next_hunk,              opts)
          vim.keymap.set("n", "[h", gs.prev_hunk,              opts)
          vim.keymap.set("n", "<leader>hs", gs.stage_hunk,     opts)
          vim.keymap.set("n", "<leader>hr", gs.reset_hunk,     opts)
          vim.keymap.set("n", "<leader>hp", gs.preview_hunk,   opts)
          vim.keymap.set("n", "<leader>hb", gs.blame_line,     opts)
          vim.keymap.set("n", "<leader>gb", gs.toggle_current_line_blame, opts)
          vim.keymap.set("n", "<leader>hd", gs.diffthis,       opts)
        end,
      })
    end,
  },

  {
    "kdheepak/lazygit.nvim",
    cmd          = "LazyGit",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" },
    },
  },

  -- ── Comment ───────────────────────────────────────────────────────────────
  {
    "numToStr/Comment.nvim",
    keys   = { "gcc", "gbc", { "gc", mode = "v" }, { "gb", mode = "v" } },
    config = true,
  },

  -- ── Auto pairs & tags ─────────────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
        ts_config = {
          javascript = { "template_string" },
        },
      })
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp           = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "typescript", "javascriptreact",
           "typescriptreact", "svelte" },
    config = true,
  },

  -- ── Colorizer ─────────────────────────────────────────────────────────────
  -- Hanya aktif di file CSS/Svelte/HTML — tidak load di Go
  {
    "NvChad/nvim-colorizer.lua",
    ft = { "css", "html", "svelte", "javascript", "typescript" },
    config = function()
      require("colorizer").setup({
        filetypes = { "css", "html", "svelte", "javascript", "typescript" },
        user_default_options = {
          tailwind = true,
          mode     = "background",
          css      = true,
        },
      })
    end,
  },

  -- ── Statusline ────────────────────────────────────────────────────────────
  -- ❌ bufferline DIHAPUS — cukup pakai lualine + Tab/S-Tab untuk navigasi buffer
  -- Alasan: bufferline render ulang setiap kali ada perubahan buffer, berat di N4020
  {
    "nvim-lualine/lualine.nvim",
    event        = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
          globalstatus         = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          -- Tambah info buffer total di kanan — pengganti bufferline
          lualine_x = { "encoding", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- ── Which Key ─────────────────────────────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        delay = 600,   -- Delay lebih panjang dari 500 → tidak trigger saat mengetik cepat
      })
      require("which-key").add({
        { "<leader>f", group = "Find (Telescope)" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Git Hunk" },
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code (LSP)" },
        { "<leader>d", group = "Diagnostics" },
        { "<leader>a", group = "AI (Codeium)" },
      })
    end,
  },

  -- ── Indent Guide ──────────────────────────────────────────────────────────
  -- Minimal mode: hanya garis indent, scope highlight dimatikan (hemat render)
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main  = "ibl",
    config = function()
      require("ibl").setup({
        indent = { char = "│" },
        scope  = { enabled = false },   -- ❌ Matikan scope highlight — hemat CPU render
        exclude = {
          filetypes = { "help", "NvimTree", "lazy", "mason",
                        "TelescopePrompt", "alpha" },
        },
      })
    end,
  },

  -- ── Todo Comments ─────────────────────────────────────────────────────────
  {
    "folke/todo-comments.nvim",
    event        = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup({
        signs    = true,
        keywords = {
          FIX  = { icon = " ", color = "error",   alt = { "FIXME", "BUG" } },
          TODO = { icon = " ", color = "info" },
          HACK = { icon = " ", color = "warning" },
          WARN = { icon = " ", color = "warning", alt = { "WARNING" } },
          NOTE = { icon = " ", color = "hint",    alt = { "INFO" } },
        },
      })
    end,
  },

  -- ── Flash ─────────────────────────────────────────────────────────────────
  {
    "folke/flash.nvim",
    event  = "VeryLazy",
    config = true,
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash Jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  -- ── Surround ──────────────────────────────────────────────────────────────
  {
    "kylechui/nvim-surround",
    event  = "VeryLazy",
    config = true,
  },

  -- ── Trouble ───────────────────────────────────────────────────────────────
  {
    "folke/trouble.nvim",
    cmd          = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config       = true,
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>",              desc = "Diagnostics (Trouble)" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer Diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>",      desc = "Symbols (Trouble)" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>",                   desc = "Quickfix (Trouble)" },
    },
  },

  -- ── Dashboard ─────────────────────────────────────────────────────────────
  {
    "goolord/alpha-nvim",
    event        = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha     = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "                                          ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
        "                                          ",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find File",     "<cmd>Telescope find_files<CR>"),
        dashboard.button("r", "  Recent Files",  "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("g", "  Live Grep",     "<cmd>Telescope live_grep<CR>"),
        dashboard.button("e", "  File Explorer", "<cmd>NvimTreeToggle<CR>"),
        dashboard.button("l", "  Lazy Plugins",  "<cmd>Lazy<CR>"),
        dashboard.button("q", "  Quit",          "<cmd>qa<CR>"),
      }

      alpha.setup(dashboard.opts)
    end,
  },

  -- ── Colorscheme ───────────────────────────────────────────────────────────
  {
    "catppuccin/nvim",
    name     = "catppuccin",
    lazy     = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour                = "mocha",
        transparent_background = false,
        integrations = {
          treesitter       = true,
          cmp              = true,
          gitsigns         = true,
          telescope        = { enabled = true },
          native_lsp       = { enabled = true },
          nvimtree         = true,
          lualine          = true,
          indent_blankline = { enabled = true },
          which_key        = true,
          alpha            = true,
          mason            = true,
          trouble          = true,
          -- bufferline = false karena tidak dipakai
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

}, {
  -- ── Lazy performance tweaks ───────────────────────────────────────────────
  performance = {
    cache = { enabled = true },
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
        "rplugin",   -- Extra: matikan remote plugin host jika tidak pakai Python provider
      },
    },
  },
  -- Checker update: matikan auto check, lakukan manual dengan :Lazy check
  checker = { enabled = false },
  change_detection = { enabled = false },  -- Jangan auto reload config saat berubah
})

-- ==================== MASON & LSP SETUP ====================
require("mason").setup({
  ui = {
    border = "rounded",
    icons  = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
  },
})

require("mason-lspconfig").setup({
  -- ❌ Dikurangi drastis: hanya Go + SvelteKit stack
  -- Tidak ada pyright, intelephense, dockerls, jsonls, yamlls, dockerls
  ensure_installed = {
    "gopls",
    "ts_ls",
    "svelte",
    "tailwindcss",
    "html",
    "cssls",
    "lua_ls",
  },
  automatic_installation = true,
})

local lspconfig    = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, silent = true }

  -- Navigation
  vim.keymap.set("n", "gd", vim.lsp.buf.definition,     opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration,    opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references,     opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

  -- Info
  vim.keymap.set("n", "K",     vim.lsp.buf.hover,          opts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)

  -- Actions
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,      opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, opts)

  -- Diagnostics
  vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,  opts)
  vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,  opts)
  vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, opts)

  -- Format
  vim.keymap.set("n", "<leader>cf", function()
    require("conform").format({ async = true, lsp_fallback = true })
  end, opts)

  -- Document highlight (highlight semua referensi kata di bawah cursor)
  -- ❌ Dimatikan untuk N4020 — CursorHold highlight mahal di file besar
  -- Aktifkan kembali kalau mau: hapus komentar di bawah
  --[[
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      buffer   = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      buffer   = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
  ]]
end

local servers = {
  -- Go: diagnosticsDelay lebih panjang dari 500ms → kurangi CPU spike saat ngetik
  gopls = {
    settings = {
      gopls = {
        analyses          = { unusedparams = true },
        staticcheck       = true,
        gofumpt           = true,
        diagnosticsDelay  = "800ms",    -- Turun ke 800ms (lebih hemat dari 500ms)
        diagnosticsTrigger = "Save",   -- Diagnosa hanya saat save, tidak saat ngetik
        -- Matikan fitur berat yang jarang dipakai
        codelenses = {
          generate         = false,
          gc_details       = false,
          regenerate_cgo   = false,
          run_govulncheck  = false,
          test             = false,
          tidy             = false,
          upgrade_dependency = false,
          vendor           = false,
        },
      },
    },
  },
  -- TypeScript: matikan format (sudah ada prettier via conform)
  ts_ls = {
    init_options = {
      preferences = {
        disableSuggestions = false,
      },
    },
    settings = {
      typescript = {
        inlayHints = {   -- Matikan inlay hints — hemat render
          includeInlayParameterNameHints = "none",
          includeInlayPropertyDeclarationTypeHints = false,
          includeInlayFunctionLikeReturnTypeHints = false,
        },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = "none",
        },
      },
    },
  },
  svelte      = {},
  tailwindcss = {},
  html        = {},
  cssls       = {},
  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
}

for server, config in pairs(servers) do
  config.on_attach    = on_attach
  config.capabilities = capabilities
  lspconfig[server].setup(config)
end

-- ==================== DIAGNOSTIC CONFIG ====================
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    source = "if_many",
    severity = nil,   -- Normal mode: tampilkan semua severity
  },
  signs            = true,
  underline        = true,
  update_in_insert = false,  -- ❌ MATIKAN update saat insert — ini penyebab lag utama di CPU lemah
  severity_sort    = true,
  float            = { border = "rounded", source = "always" },
})

local signs = { Error = "✗", Warn = "!", Hint = "»", Info = "i" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl })
end

-- ==================== AUTOCOMPLETION ====================
local cmp     = require("cmp")
local luasnip = require("luasnip")

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  window = {
    completion    = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  -- ✅ Agresif: debounce tinggi untuk N4020
  performance = {
    debounce         = 120,   -- Naik dari 60 → 120ms (kurangi trigger berlebihan)
    throttle         = 60,    -- Naik dari 30 → 60ms
    fetching_timeout = 500,
    max_view_entries = 12,    -- Turun dari 20 → 12 (lebih sedikit item = lebih cepat render)
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"]     = cmp.mapping.abort(),
    ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
    ["<C-f>"]     = cmp.mapping.scroll_docs(4),
    ["<CR>"]      = cmp.mapping.confirm({ select = false }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
      else fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then luasnip.jump(-1)
      else fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp", priority = 1000 },
    { name = "codeium",  priority = 900 },
    { name = "luasnip",  priority = 750 },
    { name = "path",     priority = 500 },
  }, {
    -- Buffer completion: hanya trigger setelah 4 karakter (hemat CPU)
    { name = "buffer", keyword_length = 4, priority = 250 },
  }),
})

-- ==================== KEYMAPS ====================

-- General
vim.keymap.set("n", "<Esc>",     ":nohlsearch<CR>",  { silent = true })
vim.keymap.set("n", "<C-s>",     ":w<CR>")
vim.keymap.set("i", "<C-s>",     "<Esc>:w<CR>a")
vim.keymap.set("n", "<leader>w", ":w<CR>",           { desc = "Save" })
vim.keymap.set("n", "<leader>q", ":q<CR>",           { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", ":qa!<CR>",         { desc = "Force Quit All" })

-- Window splits
vim.keymap.set("n", "<leader>v",  ":vsplit<CR>",  { desc = "Vertical Split" })
vim.keymap.set("n", "<leader>hh", ":split<CR>",   { desc = "Horizontal Split" })
vim.keymap.set("n", "<leader>x",  ":close<CR>",   { desc = "Close Split" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Window resize
vim.keymap.set("n", "<C-Up>",    ":resize +2<CR>",          { silent = true })
vim.keymap.set("n", "<C-Down>",  ":resize -2<CR>",          { silent = true })
vim.keymap.set("n", "<C-Left>",  ":vertical resize -2<CR>", { silent = true })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { silent = true })

-- Buffer navigation (pengganti bufferline)
vim.keymap.set("n", "<Tab>",      ":bnext<CR>",    { desc = "Next Buffer" })
vim.keymap.set("n", "<S-Tab>",    ":bprevious<CR>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>",  { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>ba", ":%bdelete|edit#|bdelete#<CR>", { desc = "Delete All Other Buffers" })

-- File explorer
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "File Explorer" })
vim.keymap.set("n", "<leader>E", ":NvimTreeFocus<CR>",  { desc = "Focus Explorer" })

-- Telescope
local tb = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", tb.find_files,            { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", tb.live_grep,             { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", tb.buffers,               { desc = "Buffers" })
vim.keymap.set("n", "<leader>fr", tb.oldfiles,              { desc = "Recent Files" })
vim.keymap.set("n", "<leader>fw", tb.grep_string,           { desc = "Grep Word" })
vim.keymap.set("n", "<leader>fh", tb.help_tags,             { desc = "Help Tags" })
vim.keymap.set("n", "<leader>fd", tb.diagnostics,           { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>fs", tb.lsp_document_symbols,  { desc = "Symbols" })
vim.keymap.set("n", "<leader>fc", tb.commands,              { desc = "Commands" })
vim.keymap.set("n", "<leader>fk", tb.keymaps,               { desc = "Keymaps" })

-- Todo
vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<CR>", { desc = "Find TODOs" })

-- Visual mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Copy/Paste
vim.keymap.set("v", "<leader>y",        '"+y',  { desc = "Yank to Clipboard" })
vim.keymap.set("n", "<leader>y",        '"+yy', { desc = "Yank Line to Clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from Clipboard" })
vim.keymap.set("v", "p", '"_dP')

-- Navigation (centered)
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n",     "nzzzv")
vim.keymap.set("n", "N",     "Nzzzv")
vim.keymap.set("n", "G",     "Gzz")

-- Search/Replace
vim.keymap.set("n", "<leader>/", "/",                             { desc = "Search" })
vim.keymap.set("n", "<leader>s", ":%s/",                          { desc = "Replace in File" })
vim.keymap.set("v", "<leader>s", ":s/",                           { desc = "Replace in Selection" })
vim.keymap.set("n", "<leader>S", ":%s/<C-r><C-w>//g<Left><Left>", { desc = "Replace Word Under Cursor" })
vim.keymap.set("n", "*",         "*zz")
vim.keymap.set("n", "#",         "#zz")

-- LazyGit
vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })

-- Codeium AI
-- Pertama kali: jalankan :Codeium Auth
vim.keymap.set("n", "<leader>aa", "<cmd>Codeium Auth<CR>",   { desc = "Codeium Auth / Login" })
vim.keymap.set("n", "<leader>at", "<cmd>Codeium Toggle<CR>", { desc = "Codeium Toggle On/Off" })
vim.keymap.set("i", "<C-g>", function() return vim.fn["codeium#Accept"]() end,
  { expr = true, desc = "Codeium Accept" })
vim.keymap.set("i", "<C-x>", function() return vim.fn["codeium#Clear"]() end,
  { expr = true, desc = "Codeium Dismiss" })
vim.keymap.set("i", "<M-]>", function() return vim.fn["codeium#CycleCompletions"](1) end,
  { expr = true, desc = "Codeium Next" })
vim.keymap.set("i", "<M-[>", function() return vim.fn["codeium#CycleCompletions"](-1) end,
  { expr = true, desc = "Codeium Prev" })

-- ==================== AUTOCOMMANDS ====================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})

-- Trailing whitespace
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern  = "*",
  command  = [[%s/\s\+$//e]],
})

-- Restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark   = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Go: 4-space indent (standar Go)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function()
    vim.opt_local.shiftwidth  = 4
    vim.opt_local.tabstop     = 4
    vim.opt_local.expandtab   = false  -- Go pakai tab asli, bukan spasi
  end,
})

-- Frontend: 2-space indent
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "typescriptreact", "javascriptreact",
              "svelte", "html", "css", "json", "yaml" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop    = 2
  end,
})

-- Close beberapa window dengan q
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "help", "lspinfo", "man", "notify", "qf",
              "startuptime", "checkhealth" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>",
      { buffer = event.buf, silent = true })
  end,
})

-- Auto create missing directories saat save
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Fix Go stale diagnostics: reset & minta ulang setelah save
-- Delay lebih panjang (500ms) karena N4020 lebih lambat index
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.go",
  callback = function()
    vim.defer_fn(function()
      local bufnr = vim.api.nvim_get_current_buf()
      vim.diagnostic.reset(nil, bufnr)
      for _, client in ipairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
        if client.name == "gopls" then
          vim.lsp.buf_notify(bufnr, "textDocument/didSave", {
            textDocument = { uri = vim.uri_from_bufnr(bufnr) },
          })
        end
      end
    end, 500)   -- Naik dari 300ms → 500ms untuk N4020
  end,
})

-- ==================== CATATAN PENTING ====================
-- ✅ update_in_insert = false: Diagnosa tidak update saat ngetik
--    → Lebih responsif, tidak lag di CPU lemah
--    → Diagnosa tetap muncul setelah kursor berhenti (CursorHold, 300ms)
--
-- ✅ bufferline DIHAPUS → gunakan Tab/S-Tab untuk ganti buffer
--    dan <leader>fb (Telescope) untuk jump ke buffer mana pun
--
-- ✅ auto_install Treesitter DIMATIKAN
--    → Install manual: :TSInstall <bahasa>  jika butuh bahasa baru
--
-- ✅ Codeium jalan di cloud, bukan lokal
--    → Tidak memakan RAM/CPU mesin kamu, aman dipertahankan
--
-- ✅ gopls codelenses dimatikan semua
--    → Bisa diaktifkan satu per satu jika diperlukan

print("⚡ Neovim Ready! (4GB RAM | Celeron N4020 | Go + SvelteKit | Codeium AI)")
