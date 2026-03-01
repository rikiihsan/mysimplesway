-- ==================== NEOVIM CONFIG — 12GB RAM / Pentium Gold 2c2t ====================
-- RAM: Bebas pakai plugin lebih banyak
-- CPU: Masih dual core, hindari plugin yang berat di background thread
-- Target: Fullstack Dev (Go, PHP, Python + React, Svelte)
-- Future proof: siap upgrade ke 4c4t (tidak ada yang perlu diubah)

-- ==================== LEADER KEY ====================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ==================== PERFORMANCE SETTINGS ====================
-- RAM sudah 12GB, tapi CPU masih 2c2t — jangan longgarkan semua limit
vim.opt.updatetime = 200        -- Lebih responsif dari sebelumnya (300 → 200)
vim.opt.timeoutlen = 400
vim.opt.lazyredraw = true       -- Tetap dipertahankan (CPU masih lemah)
vim.opt.ttyfast = true
vim.opt.synmaxcol = 300         -- Dinaikkan sedikit (RAM cukup)
vim.opt.regexpengine = 1

-- ==================== UI SETTINGS ====================
vim.opt.number = true
vim.opt.relativenumber = true   -- ✅ Diaktifkan (RAM cukup, CPU impact minimal)
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.scrolloff = 8           -- Dinaikkan (lebih nyaman coding)
vim.opt.sidescrolloff = 8
vim.opt.colorcolumn = "80,120"  -- ✅ Dua kolom marker (80 & 120)
vim.opt.cmdheight = 1
vim.opt.showmode = false        -- Mode ditampilkan oleh statusline
vim.opt.termguicolors = true

-- ==================== EDITING ====================
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.linebreak = true        -- Wrap di word boundary kalau wrap diaktifkan

-- ==================== SEARCH ====================
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- ==================== SYSTEM ====================
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.undolevels = 10000      -- ✅ Dinaikkan (RAM 12GB)
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- ==================== SPLITS ====================
vim.opt.splitright = true
vim.opt.splitbelow = true

-- ==================== COMPLETION ====================
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.pumheight = 15          -- ✅ Dinaikkan (lebih banyak item terlihat)

-- ==================== FOLDING (opsional, bisa diaktifkan) ====================
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99          -- Semua terbuka by default

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
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      -- ✅ NEU: Progress indicator untuk LSP loading
      { "j-hui/fidget.nvim", opts = { notification = { window = { winblend = 0 } } } },
      -- ✅ NEU: Neovim Lua LSP hints (berguna kalau edit config nvim)
      { "folke/neodev.nvim", opts = {} },
    },
  },

  -- ✅ NEU: Formatter yang dedicated (lebih kontrol dari lsp.buf.format)
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = "ConformInfo",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          go         = { "gofmt", "goimports" },
          python     = { "black", "isort" },
          php        = { "php_cs_fixer" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact   = { "prettier" },
          typescriptreact   = { "prettier" },
          svelte     = { "prettier" },
          html       = { "prettier" },
          css        = { "prettier" },
          json       = { "prettier" },
          markdown   = { "prettier" },
        },
        format_on_save = {
          timeout_ms = 1000,   -- Timeout agar tidak freeze di CPU lemah
          lsp_fallback = true,
        },
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
      "rafamadriz/friendly-snippets",  -- ✅ NEU: Snippet library siap pakai
    },
  },

  -- ── Fuzzy Finder ──────────────────────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- ✅ NEU: Native sorter (C extension, jauh lebih cepat di CPU lemah)
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          prompt_prefix = " > ",
          selection_caret = " ",
          layout_config = { height = 0.85, width = 0.85 },
          file_ignore_patterns = {
            "node_modules", ".git/", "vendor/", "%.lock",
            "__pycache__", "%.pyc", "dist/", "build/",
          },
          -- ✅ Penting untuk CPU lemah: batasi proses grep
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading",
            "--with-filename", "--line-number", "--column",
            "--smart-case", "--hidden",
            "--glob=!.git/",
            "--glob=!node_modules/",
            "--glob=!vendor/",
          },
        },
        pickers = {
          find_files = { hidden = true },
        },
      })
      telescope.load_extension("fzf")  -- Native sorter
    end,
  },

  -- ── File Explorer ─────────────────────────────────────────────────────────
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup({
        view = { width = 32 },
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
          highlight_git = true,         -- ✅ Highlight file berdasar git status
        },
        filters = { dotfiles = false, custom = { "^.git$" } },
        git = { enable = true },
        update_focused_file = { enable = true },  -- ✅ NEU: Sync dengan buffer aktif
        actions = {
          open_file = { quit_on_open = false },
        },
      })
    end,
  },

  -- ── Treesitter ────────────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",  -- ✅ NEU: Text objects (vaf, dif, dll)
    },
    config = function()
      require("nvim-treesitter.config").setup({
        ensure_installed = {
          "go", "python", "php",
          "javascript", "typescript", "tsx", "svelte",
          "html", "css", "scss",
          "json", "jsonc", "yaml", "toml",
          "markdown", "markdown_inline",
          "bash", "lua", "vim", "vimdoc",
          "sql",                         -- ✅ NEU: SQL highlight
          "dockerfile",                  -- ✅ NEU: Dockerfile support
          "gitignore", "gitcommit",      -- ✅ NEU: Git files
        },
        sync_install = false,
        auto_install = true,            -- ✅ Diaktifkan (RAM cukup)
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        -- ✅ NEU: Text objects (fungsi, class, parameter)
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inner",
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
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "▁" },
          topdelete = { text = "▔" },
          changedelete = { text = "▎" },
        },
        current_line_blame = false,     -- Matikan by default (bisa toggle)
        current_line_blame_opts = {
          delay = 500,                  -- Delay agar CPU tidak terus-terusan compute
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local opts = { buffer = bufnr }
          vim.keymap.set("n", "]h", gs.next_hunk, opts)
          vim.keymap.set("n", "[h", gs.prev_hunk, opts)
          vim.keymap.set("n", "<leader>hs", gs.stage_hunk, opts)
          vim.keymap.set("n", "<leader>hr", gs.reset_hunk, opts)
          vim.keymap.set("n", "<leader>hp", gs.preview_hunk, opts)
          vim.keymap.set("n", "<leader>hb", gs.blame_line, opts)
          vim.keymap.set("n", "<leader>gb", gs.toggle_current_line_blame, opts)
          vim.keymap.set("n", "<leader>hd", gs.diffthis, opts)
        end,
      })
    end,
  },

  -- ✅ NEU: Git UI (lebih nyaman dari command line git)
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" },
    },
  },

  -- ── Comment ───────────────────────────────────────────────────────────────
  {
    "numToStr/Comment.nvim",
    keys = { "gcc", "gbc", { "gc", mode = "v" }, { "gb", mode = "v" } },
    config = true,
  },

  -- ── Auto pairs & tags ─────────────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,   -- ✅ Gunakan treesitter (RAM cukup, CPU overhead minimal)
        ts_config = {
          lua = { "string" },
          javascript = { "template_string" },
        },
      })
      -- Integrasi dengan nvim-cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "typescript", "javascriptreact",
           "typescriptreact", "svelte", "xml" },
    config = true,
  },

  -- ── Colorizer ─────────────────────────────────────────────────────────────
  {
    "NvChad/nvim-colorizer.lua",
    ft = { "css", "scss", "html", "javascript", "typescript",
           "typescriptreact", "javascriptreact", "svelte" },
    config = function()
      require("colorizer").setup({
        filetypes = { "css", "scss", "html", "javascript", "typescript",
                      "typescriptreact", "javascriptreact", "svelte" },
        user_default_options = {
          tailwind = true,
          mode = "background",
          css = true,
          rgb_fn = true,
        },
      })
    end,
  },

  -- ── Find & Replace Across Project ─────────────────────────────────────────
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("spectre").setup({
        is_insert_mode = true,
        find_engine = {
          ["rg"] = {
            cmd = "rg",
            args = {
              "--color=never", "--no-heading", "--with-filename",
              "--line-number", "--column", "--iglob", "!.git",
              "--iglob", "!node_modules", "--iglob", "!vendor",
            },
            options = {
              ["ignore-case"] = { value = "--ignore-case", icon = "[I]", desc = "ignore case" },
              ["hidden"]      = { value = "--hidden", icon = "[H]", desc = "hidden file" },
            },
          },
        },
        replace_engine = { ["sed"] = { cmd = "sed", args = nil } },
        default = {
          find    = { cmd = "rg", options = { "ignore-case" } },
          replace = { cmd = "sed" },
        },
      })
    end,
  },

  -- ── Statusline ────────────────────────────────────────────────────────────
  -- ✅ NEU: Lualine (ringan, informatif, cantik)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
          globalstatus = true,   -- Satu statusline untuk semua split
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },  -- Path relatif
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- ✅ NEU: Buffer tabs (biar mirip VS Code, gampang navigasi)
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          show_buffer_close_icons = true,
          show_close_icon = false,
          separator_style = "slant",
          offsets = {
            { filetype = "NvimTree", text = "File Explorer", separator = true },
          },
        },
      })
    end,
  },

  -- ── Which Key ─────────────────────────────────────────────────────────────
  -- ✅ NEU: Popup yang bantu ingat keybinding (sangat berguna!)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        delay = 500,   -- Muncul setelah 500ms (tidak ganggu typing)
      })
      -- Register prefix labels
      require("which-key").add({
        { "<leader>f", group = "Find (Telescope)" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Git Hunk" },
        { "<leader>s", group = "Search/Replace" },
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code (LSP)" },
        { "<leader>d", group = "Diagnostics" },
      })
    end,
  },

  -- ── Indent Guide ──────────────────────────────────────────────────────────
  -- ✅ NEU: Garis indent yang membantu baca kode bersarang
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = { char = "│" },
        scope  = { enabled = true, show_start = false },
        exclude = {
          filetypes = { "help", "NvimTree", "lazy", "mason", "TelescopePrompt" },
        },
      })
    end,
  },

  -- ── Todo Comments ─────────────────────────────────────────────────────────
  -- ✅ NEU: Highlight TODO, FIXME, HACK, NOTE, dll
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup({
        signs = true,
        keywords = {
          FIX  = { icon = " ", color = "error",   alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
          TODO = { icon = " ", color = "info" },
          HACK = { icon = " ", color = "warning" },
          WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
          NOTE = { icon = " ", color = "hint",    alt = { "INFO" } },
          PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        },
      })
    end,
  },

  -- ── Flash (Better Navigation) ─────────────────────────────────────────────
  -- ✅ NEU: Jump ke mana saja dalam layar dengan cepat (pengganti hop/leap)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = true,
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,   desc = "Flash Jump" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,  desc = "Remote Flash" },
      { "<C-s>", mode = { "c" },           function() require("flash").toggle() end,  desc = "Toggle Flash Search" },
    },
  },

  -- ── Surround ──────────────────────────────────────────────────────────────
  -- ✅ NEU: Tambah/ubah/hapus surround (quotes, brackets, tags)
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = true,
    -- ys{motion}{char} = add, cs{old}{new} = change, ds{char} = delete
    -- Contoh: ysiw" = surround word dgn quote, cs"' = ganti " jadi '
  },

  -- ── Trouble ───────────────────────────────────────────────────────────────
  -- ✅ NEU: Panel diagnostics yang rapi (error, warning di seluruh project)
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = true,
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>",                        desc = "Diagnostics (Trouble)" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",           desc = "Buffer Diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>",                desc = "Symbols (Trouble)" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP Definitions (Trouble)" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>",                             desc = "Quickfix (Trouble)" },
    },
  },

  -- ── Dashboard ─────────────────────────────────────────────────────────────
  -- ✅ NEU: Start screen yang rapi saat buka nvim tanpa file
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "                                                     ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
        "                                                     ",
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
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        integrations = {
          treesitter    = true,
          cmp           = true,
          gitsigns      = true,
          telescope     = { enabled = true },
          native_lsp    = { enabled = true },
          nvimtree      = true,
          bufferline    = true,
          lualine       = true,
          indent_blankline = { enabled = true },
          which_key     = true,
          alpha         = true,
          mason         = true,
          trouble       = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

}, {
  -- Lazy.nvim options
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})

-- ==================== LSP SETUP ====================
require("mason").setup({
  ui = {
    border = "rounded",
    icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
  },
})

require("mason-lspconfig").setup({
  ensure_installed = {
    "gopls",        -- Go
    "pyright",      -- Python
    "intelephense", -- PHP
    "ts_ls",        -- TypeScript/JavaScript
    "svelte",       -- Svelte
    "tailwindcss",  -- Tailwind
    "html",         -- HTML
    "cssls",        -- CSS
    "jsonls",       -- JSON            ✅ NEU
    "yamlls",       -- YAML            ✅ NEU
    "lua_ls",       -- Lua (untuk config nvim) ✅ NEU
    "dockerls",     -- Dockerfile      ✅ NEU
  },
  automatic_installation = true,
})

local lspconfig   = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, silent = true }

  -- Navigation
  vim.keymap.set("n", "gd",  vim.lsp.buf.definition,      opts)
  vim.keymap.set("n", "gD",  vim.lsp.buf.declaration,      opts)
  vim.keymap.set("n", "gr",  vim.lsp.buf.references,       opts)
  vim.keymap.set("n", "gi",  vim.lsp.buf.implementation,   opts)
  vim.keymap.set("n", "gt",  vim.lsp.buf.type_definition,  opts)

  -- Info
  vim.keymap.set("n", "K",          vim.lsp.buf.hover,           opts)
  vim.keymap.set("n", "<C-k>",      vim.lsp.buf.signature_help,  opts)
  vim.keymap.set("i", "<C-k>",      vim.lsp.buf.signature_help,  opts)

  -- Actions
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,       opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,  opts)
  vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action,  opts)

  -- Diagnostics
  vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,   opts)
  vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,   opts)
  vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float,  opts)
  vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist,  opts)

  -- Format (pakai conform kalau tersedia, fallback ke LSP)
  vim.keymap.set("n", "<leader>cf", function()
    require("conform").format({ async = true, lsp_fallback = true })
  end, opts)

  -- Highlight word under cursor via LSP (kalau server support)
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

local servers = {
  gopls        = {
    settings = {
      gopls = {
        analyses = { unusedparams = true },
        staticcheck = true,
        gofumpt = true,
      },
    },
  },
  pyright      = {
    settings = {
      python = {
        analysis = { typeCheckingMode = "basic" },  -- "off"/"basic"/"strict"
      },
    },
  },
  intelephense = {},
  ts_ls        = {},
  svelte       = {},
  tailwindcss  = {},
  html         = {},
  cssls        = {},
  jsonls       = {},
  yamlls       = {},
  lua_ls       = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  dockerls     = {},
}

for server, config in pairs(servers) do
  config.on_attach    = on_attach
  config.capabilities = capabilities
  lspconfig[server].setup(config)
end

-- Diagnostic display
vim.diagnostic.config({
  virtual_text = { prefix = "●", source = "if_many" },
  signs        = true,
  underline    = true,
  update_in_insert = false,
  severity_sort    = true,
  float = { border = "rounded", source = "always" },
})

local signs = { Error = "✗", Warn = "!", Hint = "»", Info = "i" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl })
end

-- ==================== AUTOCOMPLETION ====================
local cmp     = require("cmp")
local luasnip = require("luasnip")

-- Load friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  window = {
    completion    = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
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
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "path" },
  }, {
    { name = "buffer", keyword_length = 3 },
  }),
})



-- ==================== KEYMAPS ====================

-- General
vim.keymap.set("n", "<Esc>",      ":nohlsearch<CR>",   { silent = true })
vim.keymap.set("n", "<C-s>",      ":w<CR>")
vim.keymap.set("i", "<C-s>",      "<Esc>:w<CR>a")
vim.keymap.set("n", "<leader>w",  ":w<CR>",            { desc = "Save" })
vim.keymap.set("n", "<leader>q",  ":q<CR>",            { desc = "Quit" })
vim.keymap.set("n", "<leader>Q",  ":qa!<CR>",          { desc = "Force Quit All" })

-- Window splits
vim.keymap.set("n", "<leader>v",  ":vsplit<CR>",       { desc = "Vertical Split" })
vim.keymap.set("n", "<leader>hh", ":split<CR>",        { desc = "Horizontal Split" })
vim.keymap.set("n", "<leader>x",  ":close<CR>",        { desc = "Close Split" })

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

-- Buffer management
vim.keymap.set("n", "<Tab>",       ":bnext<CR>",    { desc = "Next Buffer" })
vim.keymap.set("n", "<S-Tab>",     ":bprevious<CR>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<leader>bd",  ":bdelete<CR>",  { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>ba",  ":%bdelete|edit#|bdelete#<CR>", { desc = "Delete All Other Buffers" })

-- File explorer
vim.keymap.set("n", "<leader>e",   ":NvimTreeToggle<CR>",  { desc = "File Explorer" })
vim.keymap.set("n", "<leader>E",   ":NvimTreeFocus<CR>",   { desc = "Focus Explorer" })

-- Telescope
local tb = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", tb.find_files,               { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", tb.live_grep,                { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", tb.buffers,                  { desc = "Buffers" })
vim.keymap.set("n", "<leader>fr", tb.oldfiles,                 { desc = "Recent Files" })
vim.keymap.set("n", "<leader>fw", tb.grep_string,              { desc = "Grep Word" })
vim.keymap.set("n", "<leader>fh", tb.help_tags,                { desc = "Help Tags" })
vim.keymap.set("n", "<leader>fd", tb.diagnostics,              { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>fs", tb.lsp_document_symbols,     { desc = "Symbols" })
vim.keymap.set("n", "<leader>fS", tb.lsp_workspace_symbols,    { desc = "Workspace Symbols" })
vim.keymap.set("n", "<leader>fc", tb.commands,                 { desc = "Commands" })
vim.keymap.set("n", "<leader>fk", tb.keymaps,                  { desc = "Keymaps" })

-- Todo comments
vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<CR>",    { desc = "Find TODOs" })

-- Find and Replace (Spectre)
vim.keymap.set("n", "<leader>sr", function() require("spectre").open() end,                        { desc = "Open Spectre" })
vim.keymap.set("n", "<leader>sw", function() require("spectre").open_visual({ select_word=true }) end, { desc = "Search Word" })
vim.keymap.set("v", "<leader>sw", function() require("spectre").open_visual() end,                 { desc = "Search Selection" })
vim.keymap.set("n", "<leader>sf", function() require("spectre").open_file_search({ select_word=true }) end, { desc = "Search in File" })

-- Visual mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Copy/Paste
vim.keymap.set("v", "<leader>y", '"+y',   { desc = "Yank to Clipboard" })
vim.keymap.set("n", "<leader>y", '"+yy',  { desc = "Yank Line to Clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from Clipboard" })
vim.keymap.set("v", "p", '"_dP')

-- Navigation (centered)
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n",     "nzzzv")
vim.keymap.set("n", "N",     "Nzzzv")
vim.keymap.set("n", "G",     "Gzz")

-- Search
vim.keymap.set("n", "<leader>/",  "/",                                     { desc = "Search" })
vim.keymap.set("n", "<leader>s",  ":%s/",                                  { desc = "Replace in File" })
vim.keymap.set("v", "<leader>s",  ":s/",                                   { desc = "Replace in Selection" })
vim.keymap.set("n", "<leader>S",  ":%s/<C-r><C-w>//g<Left><Left>",         { desc = "Replace Word Under Cursor" })
vim.keymap.set("n", "*",          "*zz")
vim.keymap.set("n", "#",          "#zz")

-- LazyGit
vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })

-- ==================== AUTOCOMMANDS ====================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Trailing whitespace
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Restore cursor
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark   = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Frontend: 2-space indent
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "typescriptreact", "javascriptreact",
              "svelte", "html", "css", "scss", "json", "yaml" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop    = 2
  end,
})

-- Close beberapa window dengan q
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "help", "lspinfo", "man", "notify", "qf", "spectre_panel",
              "startuptime", "tsplayground", "checkhealth" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
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

print("⚡ Neovim Ready! (12GB RAM Build)")
