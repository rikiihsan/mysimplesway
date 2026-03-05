-- ==================== NEOVIM CONFIG — 12GB RAM / Pentium Gold G3260 2c2t ====================
-- RAM: Bebas pakai plugin lebih banyak
-- CPU: Dual core Haswell 3.3GHz — hindari background thread berat
-- Target: Fullstack Dev (Go, PHP, Python + React, Svelte)
-- Changelog:
--   + Codeium AI autocomplete (ghost text + cmp source)
--   + nvim-cmp debounce & optimasi
--   + Go LSP false positive fix (stale diagnostics)
--   + Deteksi error saat ngetik (insert mode, Error only)
--   + Responsivitas: updatetime 100, hapus lazyredraw, LSP debounce

-- ==================== LEADER KEY ====================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ==================== PERFORMANCE SETTINGS ====================
vim.opt.updatetime = 100         -- ✅ Turun dari 200 → 100 (lebih responsif CursorHold)
vim.opt.timeoutlen = 400
-- ❌ lazyredraw DIHAPUS — di Neovim modern justru bikin input lag & glitch
vim.opt.ttyfast = true
vim.opt.synmaxcol = 300
vim.opt.regexpengine = 1

-- ==================== UI SETTINGS ====================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.colorcolumn = "80,120"
vim.opt.cmdheight = 1
vim.opt.showmode = false
vim.opt.termguicolors = true

-- ==================== EDITING ====================
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.linebreak = true

-- ==================== SEARCH ====================
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- ==================== SYSTEM ====================
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- ==================== SPLITS ====================
vim.opt.splitright = true
vim.opt.splitbelow = true

-- ==================== COMPLETION ====================
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.pumheight = 15

-- ==================== FOLDING ====================
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99

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
      { "j-hui/fidget.nvim", opts = { notification = { window = { winblend = 0 } } } },
      { "folke/neodev.nvim", opts = {} },
    },
  },

  -- ── Formatter ─────────────────────────────────────────────────────────────
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
          timeout_ms = 1000,
          lsp_fallback = true,
        },
      })
    end,
  },

  -- ── AI Autocomplete: Codeium ──────────────────────────────────────────────
  -- ✅ NEU: Ghost text AI completion — :Codeium Auth untuk login pertama kali
  {
    "Exafunction/codeium.nvim",
    event = "InsertEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({
        -- Virtual text (ghost text) mode
        enable_chat = false,   -- Matikan chat UI, hemat CPU
        -- Codeium akan otomatis terhubung ke akun lewat :Codeium Auth
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
      -- ✅ Codeium sebagai cmp source (muncul di dropdown bersama LSP)
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
          prompt_prefix = " > ",
          selection_caret = " ",
          layout_config = { height = 0.85, width = 0.85 },
          file_ignore_patterns = {
            "node_modules", ".git/", "vendor/", "%.lock",
            "__pycache__", "%.pyc", "dist/", "build/",
          },
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
      telescope.load_extension("fzf")
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
          highlight_git = true,
        },
        filters = { dotfiles = false, custom = { "^.git$" } },
        git = { enable = true },
        update_focused_file = { enable = true },
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
      "nvim-treesitter/nvim-treesitter-textobjects",
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
          "sql",
          "dockerfile",
          "gitignore", "gitcommit",
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
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
        current_line_blame = false,
        current_line_blame_opts = { delay = 500 },
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
        check_ts = true,
        ts_config = {
          lua = { "string" },
          javascript = { "template_string" },
        },
      })
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
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

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
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        delay = 500,
      })
      require("which-key").add({
        { "<leader>f", group = "Find (Telescope)" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Git Hunk" },
        { "<leader>s", group = "Search/Replace" },
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code (LSP)" },
        { "<leader>d", group = "Diagnostics" },
        { "<leader>a", group = "AI (Codeium)" },  -- ✅ NEU
      })
    end,
  },

  -- ── Indent Guide ──────────────────────────────────────────────────────────
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

  -- ── Flash ─────────────────────────────────────────────────────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = true,
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,        desc = "Flash Jump" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,  desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,       desc = "Remote Flash" },
      { "<C-s>", mode = { "c" },           function() require("flash").toggle() end,       desc = "Toggle Flash Search" },
    },
  },

  -- ── Surround ──────────────────────────────────────────────────────────────
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = true,
  },

  -- ── Trouble ───────────────────────────────────────────────────────────────
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
    "gopls",
    "pyright",
    "intelephense",
    "ts_ls",
    "svelte",
    "tailwindcss",
    "html",
    "cssls",
    "jsonls",
    "yamlls",
    "lua_ls",
    "dockerls",
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
  vim.keymap.set("n", "K",     vim.lsp.buf.hover,           opts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help,  opts)
  vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help,  opts)

  -- Actions
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,       opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,  opts)
  vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action,  opts)

  -- Diagnostics
  vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,   opts)
  vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,   opts)
  vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float,  opts)
  vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist,  opts)

  -- Format
  vim.keymap.set("n", "<leader>cf", function()
    require("conform").format({ async = true, lsp_fallback = true })
  end, opts)

  -- Highlight word under cursor
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
  gopls = {
    settings = {
      gopls = {
        analyses = { unusedparams = true },
        staticcheck = true,
        gofumpt = true,
        -- ✅ NEU: Debounce diagnostic agar tidak flood saat ngetik
        diagnosticsDelay = "500ms",
        -- ✅ NEU: Paksa gopls refresh setelah save
        diagnosticsTrigger = "Save",
      },
    },
  },
  pyright = {
    settings = {
      python = {
        analysis = { typeCheckingMode = "basic" },
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
  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  dockerls = {},
}

for server, config in pairs(servers) do
  config.on_attach    = on_attach
  config.capabilities = capabilities
  lspconfig[server].setup(config)
end

-- ==================== DIAGNOSTIC CONFIG ====================
-- ✅ update_in_insert = true tapi hanya tampilkan ERROR (bukan Warning)
--    supaya tidak berisik saat ngetik, tapi langsung tahu ada syntax error
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    source = "if_many",
    -- ✅ Filter: saat insert mode hanya tampil Error, normal mode semua
    severity = nil,  -- normal mode: semua severity
  },
  signs = true,
  underline = true,
  update_in_insert = true,   -- ✅ Aktif saat ngetik (real-time detection)
  severity_sort = true,
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

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  window = {
    completion    = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  -- ✅ NEU: Performance — batasi berapa item di-render sekaligus
  performance = {
    debounce          = 60,   -- Delay sebelum trigger completion (ms)
    throttle          = 30,   -- Throttle update list (ms)
    fetching_timeout  = 500,  -- Timeout per source
    max_view_entries  = 20,   -- Max item ditampilkan (hemat render CPU)
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
    { name = "nvim_lsp",  priority = 1000 },
    { name = "codeium",   priority = 900 },   -- ✅ NEU: Codeium AI source
    { name = "luasnip",   priority = 750 },
    { name = "path",      priority = 500 },
  }, {
    { name = "buffer", keyword_length = 3, priority = 250 },
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
vim.keymap.set("n", "<leader>sr", function() require("spectre").open() end,                           { desc = "Open Spectre" })
vim.keymap.set("n", "<leader>sw", function() require("spectre").open_visual({ select_word=true }) end, { desc = "Search Word" })
vim.keymap.set("v", "<leader>sw", function() require("spectre").open_visual() end,                    { desc = "Search Selection" })
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
vim.keymap.set("n", "<leader>/",  "/",                                      { desc = "Search" })
vim.keymap.set("n", "<leader>s",  ":%s/",                                   { desc = "Replace in File" })
vim.keymap.set("v", "<leader>s",  ":s/",                                    { desc = "Replace in Selection" })
vim.keymap.set("n", "<leader>S",  ":%s/<C-r><C-w>//g<Left><Left>",          { desc = "Replace Word Under Cursor" })
vim.keymap.set("n", "*",          "*zz")
vim.keymap.set("n", "#",          "#zz")

-- LazyGit
vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })

-- ✅ NEU: Codeium AI keymaps
-- Jalankan :Codeium Auth pertama kali untuk login
vim.keymap.set("n", "<leader>aa", "<cmd>Codeium Auth<CR>",    { desc = "Codeium Auth / Login" })
vim.keymap.set("n", "<leader>at", "<cmd>Codeium Toggle<CR>",  { desc = "Codeium Toggle On/Off" })
-- Accept/dismiss ghost text saat insert mode
vim.keymap.set("i", "<C-g>",  function() return vim.fn["codeium#Accept"]() end,       { expr = true, desc = "Codeium Accept" })
vim.keymap.set("i", "<C-x>",  function() return vim.fn["codeium#Clear"]() end,        { expr = true, desc = "Codeium Dismiss" })
vim.keymap.set("i", "<M-]>",  function() return vim.fn["codeium#CycleCompletions"](1) end,  { expr = true, desc = "Codeium Next" })
vim.keymap.set("i", "<M-[>",  function() return vim.fn["codeium#CycleCompletions"](-1) end, { expr = true, desc = "Codeium Prev" })

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

-- ✅ NEU: Fix Go stale diagnostics — flush & re-request setiap BufWritePost
--    Ini mengatasi masalah "kode sudah benar tapi error lama tidak hilang"
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.go",
  callback = function()
    -- Kecil delay agar gopls selesai index dulu baru kita reset
    vim.defer_fn(function()
      local bufnr = vim.api.nvim_get_current_buf()
      -- Reset diagnostic lama di buffer ini
      vim.diagnostic.reset(nil, bufnr)
      -- Minta LSP kirim ulang diagnostic terbaru
      for _, client in ipairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
        if client.name == "gopls" then
          -- Trigger diagnostic refresh via didSave notification
          vim.lsp.buf_notify(bufnr, "textDocument/didSave", {
            textDocument = { uri = vim.uri_from_bufnr(bufnr) },
          })
        end
      end
    end, 300)  -- 300ms setelah save, gopls seharusnya sudah selesai parse
  end,
})

-- ✅ NEU: Saat masuk insert mode, sembunyikan Warning/Hint
--    Biarkan Error saja yang tampil supaya tidak noisy
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    vim.diagnostic.config({
      virtual_text = {
        prefix = "●",
        source = "if_many",
        severity = { min = vim.diagnostic.severity.ERROR },
      },
    })
  end,
})

-- ✅ NEU: Saat keluar insert mode, kembalikan semua severity
vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    vim.diagnostic.config({
      virtual_text = {
        prefix = "●",
        source = "if_many",
        severity = nil,  -- semua severity tampil lagi
      },
    })
  end,
})

print("⚡ Neovim Ready! (12GB RAM | Codeium AI | Go Fix)")
