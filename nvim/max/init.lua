
---

# init.lua (Clean Version - No Comments)

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.updatetime = 100
vim.opt.timeoutlen = 400
vim.opt.ttyfast = true
vim.opt.synmaxcol = 300
vim.opt.regexpengine = 1

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
vim.opt.showtabline = 0
vim.opt.pumheight = 15

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.linebreak = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.completeopt = "menu,menuone,noselect"

vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99

vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Aktifkan Treesitter folding setelah buffer siap",
  callback = function(args)
    local ok = pcall(function()
      vim.treesitter.get_parser(args.buf)
    end)
    if ok then
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
    end
  end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

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

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = "ConformInfo",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          go = { "gofmt", "goimports" },
          python = { "black", "isort" },
          php = { "php_cs_fixer" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          svelte = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          json = { "prettier" },
          markdown = { "prettier" },
        },
        format_on_save = {
          timeout_ms = 1000,
          lsp_fallback = true,
        },
      })
    end,
  },

  {
    "Exafunction/codeium.nvim",
    event = "InsertEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({
        enable_chat = false,
        virtual_text = {
          enabled = true,
        },
      })
    end,
  },

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
          "sql", "dockerfile",
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

  {
    "numToStr/Comment.nvim",
    keys = { "gcc", "gbc", { "gc", mode = "v" }, { "gb", mode = "v" } },
    config = true,
  },

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
    ft = {
      "html", "javascript", "typescript",
      "javascriptreact", "typescriptreact", "svelte", "xml",
    },
    config = true,
  },

  {
    "NvChad/nvim-colorizer.lua",
    ft = {
      "css", "scss", "html", "javascript", "typescript",
      "typescriptreact", "javascriptreact", "svelte",
    },
    config = function()
      require("colorizer").setup({
        filetypes = {
          "css", "scss", "html", "javascript", "typescript",
          "typescriptreact", "javascriptreact", "svelte",
        },
        user_default_options = {
          tailwind = true,
          mode = "background",
          css = true,
          rgb_fn = true,
        },
      })
    end,
  },

  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local missing = {}
      if vim.fn.executable("rg") == 0 then table.insert(missing, "ripgrep (rg)") end
      if vim.fn.executable("sed") == 0 then table.insert(missing, "sed") end

      if #missing > 0 then
        vim.notify(
          "nvim-spectre: binary tidak ditemukan -> " .. table.concat(missing, ", "),
          vim.log.levels.WARN,
          { title = "Spectre" }
        )
        return
      end

      require("spectre").setup({
        is_insert_mode = true,
        find_engine = {
          ["rg"] = {
            cmd = "rg",
            args = {
              "--color=never", "--no-heading", "--with-filename",
              "--line-number", "--column",
              "--iglob", "!.git",
              "--iglob", "!node_modules",
              "--iglob", "!vendor",
            },
            options = {
              ["ignore-case"] = { value = "--ignore-case", icon = "[I]", desc = "ignore case" },
              ["hidden"] = { value = "--hidden", icon = "[H]", desc = "hidden file" },
            },
          },
        },
        replace_engine = { ["sed"] = { cmd = "sed", args = nil } },
        default = {
          find = { cmd = "rg", options = { "ignore-case" } },
          replace = { cmd = "sed" },
        },
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
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
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({ delay = 500 })
      require("which-key").add({
        { "<leader>f", group = "Find (Telescope)" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Git Hunk" },
        { "<leader>s", group = "Search/Replace" },
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code (LSP)" },
        { "<leader>d", group = "Diagnostics" },
        { "<leader>a", group = "AI (Codeium)" },
        { "<leader>w", group = "Window/Split" },
      })
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = { char = "│" },
        scope = { enabled = true, show_start = false },
        exclude = {
          filetypes = { "help", "NvimTree", "lazy", "mason", "TelescopePrompt" },
        },
      })
    end,
  },

  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup({
        signs = true,
        keywords = {
          FIX = { icon = "", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
          TODO = { icon = "", color = "info" },
          HACK = { icon = "", color = "warning" },
          WARN = { icon = "", color = "warning", alt = { "WARNING", "XXX" } },
          NOTE = { icon = "", color = "hint", alt = { "INFO" } },
          PERF = { icon = "", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        },
      })
    end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = true,
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "<C-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = true,
  },

  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = true,
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer Diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Symbols (Trouble)" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP Definitions (Trouble)" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix (Trouble)" },
    },
  },

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
        dashboard.button("f", "  Find File", "<cmd>Telescope find_files<CR>"),
        dashboard.button("r", "  Recent Files", "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("g", "  Live Grep", "<cmd>Telescope live_grep<CR>"),
        dashboard.button("e", "  File Explorer", "<cmd>NvimTreeToggle<CR>"),
        dashboard.button("l", "  Lazy Plugins", "<cmd>Lazy<CR>"),
        dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
      }

      alpha.setup(dashboard.opts)
    end,
  },

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
          treesitter = true,
          cmp = true,
          gitsigns = true,
          telescope = { enabled = true },
          native_lsp = { enabled = true },
          nvimtree = true,
          lualine = true,
          indent_blankline = { enabled = true },
          which_key = true,
          alpha = true,
          mason = true,
          trouble = true,
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

require("mason").setup({
  ui = {
    border = "rounded",
    icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
  },
})

require("mason-lspconfig").setup({
  ensure_installed = {
    "gopls", "pyright", "intelephense", "ts_ls", "svelte",
    "tailwindcss", "html", "cssls", "jsonls", "yamlls",
    "lua_ls", "dockerls",
  },
  automatic_installation = true,
})

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, silent = true }

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, opts)
  vim.keymap.set("n", "<leader>cf", function()
    require("conform").format({ async = true, lsp_fallback = true })
  end, opts)

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
        diagnosticsDelay = "500ms",
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
  ts_ls = {},
  svelte = {},
  tailwindcss = {},
  html = {},
  cssls = {},
  jsonls = {},
  yamlls = {},
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
  config.on_attach = on_attach
  config.capabilities = capabilities
  lspconfig[server].setup(config)
end

vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    source = "if_many",
    severity = nil,
  },
  signs = true,
  underline = true,
  update_in_insert = true,
  severity_sort = true,
  float = { border = "rounded", source = "always" },
})

local signs = { Error = "✗", Warn = "!", Hint = "»", Info = "i" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl })
end

local cmp = require("cmp")
local luasnip = require("luasnip")

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  performance = {
    debounce = 60,
    throttle = 30,
    fetching_timeout = 500,
    max_view_entries = 20,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp", priority = 1000 },
    { name = "codeium", priority = 900 },
    { name = "luasnip", priority = 750 },
    { name = "path", priority = 500 },
  }, {
    { name = "buffer", keyword_length = 3, priority = 250 },
  }),
})

vim.keymap.set("n", "<C-c>", '"+yy', { desc = "Copy Line to Clipboard", silent = true })
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy Selection to Clipboard", silent = true })
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank ke Clipboard" })
vim.keymap.set("n", "<leader>y", '"+yy', { desc = "Yank Baris ke Clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste dari Clipboard" })
vim.keymap.set("v", "p", '"_dP')
vim.keymap.set({ "n", "v" }, "<C-v>", '"+p', { desc = "Paste dari Clipboard" })

vim.keymap.set("n", "<leader>s", ":w<CR>", { desc = "Save File" })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a")
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", ":qa!<CR>", { desc = "Force Quit All" })

vim.keymap.set("n", "<leader>h", ":split<CR>", { desc = "Horizontal Split" })
vim.keymap.set("n", "<leader>v", ":vsplit<CR>", { desc = "Vertical Split" })
vim.keymap.set("n", "<leader>wc", ":close<CR>", { desc = "Tutup Split Aktif" })
vim.keymap.set("n", "<leader>wo", ":only<CR>", { desc = "Tutup Split Lain" })

vim.keymap.set("n", "<leader>wf", function()
  require("telescope.builtin").find_files({
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local selected = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)
        if selected then
          vim.cmd("vsplit " .. vim.fn.fnameescape(selected.path))
        end
      end)
      return true
    end,
  })
end, { desc = "Buka File di VSplit Baru" })

vim.keymap.set("n", "<leader>wg", function()
  require("telescope.builtin").find_files({
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local selected = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)
        if selected then
          vim.cmd("split " .. vim.fn.fnameescape(selected.path))
        end
      end)
      return true
    end,
  })
end, { desc = "Buka File di HSplit Baru" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Pindah ke split Kiri" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Pindah ke split Bawah" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Pindah ke split Atas" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Pindah ke split Kanan" })

vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { silent = true })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { silent = true })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { silent = true })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { silent = true })

vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Hapus Buffer" })
vim.keymap.set("n", "<leader>ba", ":%bdelete|edit#|bdelete#<CR>", { desc = "Hapus Semua Buffer Lain" })

vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "File Explorer" })
vim.keymap.set("n", "<leader>E", ":NvimTreeFocus<CR>", { desc = "Focus Explorer" })

local tb = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", tb.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", tb.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", tb.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fr", tb.oldfiles, { desc = "Recent Files" })
vim.keymap.set("n", "<leader>fw", tb.grep_string, { desc = "Grep Word" })
vim.keymap.set("n", "<leader>fh", tb.help_tags, { desc = "Help Tags" })
vim.keymap.set("n", "<leader>fd", tb.diagnostics, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>fs", tb.lsp_document_symbols, { desc = "Symbols" })
vim.keymap.set("n", "<leader>fS", tb.lsp_workspace_symbols, { desc = "Workspace Symbols" })
vim.keymap.set("n", "<leader>fc", tb.commands, { desc = "Commands" })
vim.keymap.set("n", "<leader>fk", tb.keymaps, { desc = "Keymaps" })

vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<CR>", { desc = "Find TODOs" })

vim.keymap.set("n", "<leader>sr", function() require("spectre").open() end, { desc = "Open Spectre" })
vim.keymap.set("n", "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, { desc = "Search Word" })
vim.keymap.set("v", "<leader>sw", function() require("spectre").open_visual() end, { desc = "Search Selection" })
vim.keymap.set("n", "<leader>sf", function() require("spectre").open_file_search({ select_word = true }) end, { desc = "Search in File" })

vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { silent = true })
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "G", "Gzz")

vim.keymap.set("n", "<leader>/", "/", { desc = "Search" })
vim.keymap.set("n", "<leader>S", ":%s/", { desc = "Replace in File" })
vim.keymap.set("v", "<leader>S", ":s/", { desc = "Replace in Selection" })
vim.keymap.set("n", "<leader>SR", ":%s/<C-r><C-w>//g<Left><Left>", { desc = "Replace Word Under Cursor" })
vim.keymap.set("n", "*", "*zz")
vim.keymap.set("n", "#", "#zz")

vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })

vim.keymap.set("n", "<leader>aa", "<cmd>Codeium Auth<CR>", { desc = "Codeium Auth" })
vim.keymap.set("n", "<leader>at", "<cmd>Codeium Toggle<CR>", { desc = "Codeium Toggle" })
vim.keymap.set("i", "<C-g>", function() return vim.fn["codeium#Accept"]() end, { expr = true, desc = "Codeium Accept" })
vim.keymap.set("i", "<C-x>", function() return vim.fn["codeium#Clear"]() end, { expr = true, desc = "Codeium Dismiss" })
vim.keymap.set("i", "<M-]>", function() return vim.fn["codeium#CycleCompletions"](1) end, { expr = true, desc = "Codeium Next" })
vim.keymap.set("i", "<M-[>", function() return vim.fn["codeium#CycleCompletions"](-1) end, { expr = true, desc = "Codeium Prev" })

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename", buffer = true })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action", buffer = true })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover", buffer = true })

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics" })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Remove trailing whitespace",
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Restore cursor position",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "2-space indent for frontend files",
  pattern = {
    "javascript", "typescript", "typescriptreact", "javascriptreact",
    "svelte", "html", "css", "scss", "json", "yaml",
  },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Close utility windows with q",
  pattern = {
    "help", "lspinfo", "man", "notify", "qf", "spectre_panel",
    "startuptime", "tsplayground", "checkhealth",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Create missing directories",
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  desc = "Reset Go diagnostics after save",
  pattern = "*.go",
  callback = function()
    vim.defer_fn(function()
      local bufnr = vim.api.nvim_get_current_buf()
      vim.diagnostic.reset(nil, bufnr)
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if client.name == "gopls" then
          vim.lsp.buf_notify(bufnr, "textDocument/didSave", {
            textDocument = { uri = vim.uri_from_bufnr(bufnr) },
          })
        end
      end
    end, 300)
  end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  desc = "Insert mode: show only errors",
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

vim.api.nvim_create_autocmd("InsertLeave", {
  desc = "Normal mode: show all diagnostics",
  callback = function()
    vim.diagnostic.config({
      virtual_text = {
        prefix = "●",
        source = "if_many",
        severity = nil,
      },
    })
  end,
})

print("Neovim Ready)
