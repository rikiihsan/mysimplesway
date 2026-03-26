
---

# init.lua (Clean Version - No Comments)

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.updatetime = 200
vim.opt.timeoutlen = 500
vim.opt.ttyfast = true
vim.opt.synmaxcol = 200
vim.opt.regexpengine = 1
vim.opt.lazyredraw = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.colorcolumn = "80"
vim.opt.cmdheight = 1
vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.showtabline = 0
vim.opt.pumheight = 10

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
vim.opt.undolevels = 5000
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize"

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.completeopt = "menu,menuone,noselect"

vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99

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
          go = { "gofmt" },
          python = { "black" },
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
          timeout_ms = 2000,
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
          enabled = false,
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
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          prompt_prefix = " > ",
          selection_caret = " ",
          layout_config = { height = 0.75, width = 0.75 },
          file_ignore_patterns = {
            "node_modules", ".git/", "vendor/", "%.lock",
            "__pycache__", "%.pyc", "dist/", "build/",
          },
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading",
            "--with-filename", "--line-number", "--column",
            "--smart-case",
            "--glob=!.git/",
            "--glob=!node_modules/",
            "--glob=!vendor/",
          },
          performance = {
            caching = true,
            cache_size = 500,
          },
        },
        pickers = {
          find_files = { hidden = false },
        },
      })
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
        view = { width = 28 },
        renderer = {
          root_folder_label = ":~:s?$?/..?",
          icons = {
            show = { git = false, folder = true, file = true },
            glyphs = {
              default = "",
              symlink = "",
              folder = {
                default = "", open = "", empty = "",
                empty_open = "", symlink = "",
              },
            },
          },
          highlight_git = false,
        },
        filters = { dotfiles = true, custom = { "^.git$" } },
        git = { enable = false },
        update_focused_file = { enable = false },
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
    config = function()
      require("nvim-treesitter.config").setup({
        ensure_installed = {
          "go", "python", "php",
          "javascript", "typescript", "tsx",
          "html", "css",
          "json", "yaml",
          "bash", "lua", "vim",
          "markdown",
        },
        sync_install = false,
        auto_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          disable = function(lang, buf)
            local max_filesize = 500 * 1024
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
        },
        indent = { enable = false },
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
        current_line_blame_opts = { delay = 1000 },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local opts = { buffer = bufnr }
          vim.keymap.set("n", "]h", gs.next_hunk, opts)
          vim.keymap.set("n", "[h", gs.prev_hunk, opts)
          vim.keymap.set("n", "<leader>hs", gs.stage_hunk, opts)
          vim.keymap.set("n", "<leader>hr", gs.reset_hunk, opts)
        end,
      })
    end,
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
        check_ts = false,
      })
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
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
          lualine_b = { "branch", "diff" },
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
        { "<leader>s", group = "Save/Search" },
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code (LSP)" },
        { "<leader>d", group = "Diagnostics" },
        { "<leader>a", group = "AI (Codeium)" },
        { "<leader>w", group = "Window/Split" },
      })
    end,
  },

  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup({
        signs = false,
        keywords = {
          FIX = { icon = "", color = "error" },
          TODO = { icon = "", color = "info" },
          HACK = { icon = "", color = "warning" },
          WARN = { icon = "", color = "warning" },
          NOTE = { icon = "", color = "hint" },
        },
      })
    end,
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
          which_key = true,
          alpha = true,
          mason = true,
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
    cache = {
      enabled = true,
    },
  },
  install = {
    colorscheme = { "catppuccin" },
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
    "gopls", "pyright", "intelephense", "ts_ls",
    "html", "cssls", "jsonls",
    "lua_ls",
  },
  automatic_installation = false,
})

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, silent = true }

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "<leader>cf", function()
    require("conform").format({ async = true, lsp_fallback = true })
  end, opts)
end

local servers = {
  gopls = {
    settings = {
      gopls = {
        analyses = { unusedparams = false },
        staticcheck = false,
        gofumpt = true,
        diagnosticsDelay = "1000ms",
        diagnosticsTrigger = "Save",
      },
    },
  },
  pyright = {
    settings = {
      python = {
        analysis = { typeCheckingMode = "off" },
      },
    },
  },
  intelephense = {},
  ts_ls = {},
  html = {},
  cssls = {},
  jsonls = {},
  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        runtime = { version = "LuaJIT" },
      },
    },
  },
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
  underline = false,
  update_in_insert = false,
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
    debounce = 100,
    throttle = 60,
    fetching_timeout = 800,
    max_view_entries = 10,
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
    { name = "path", priority = 500 },
  }, {
    { name = "buffer", keyword_length = 5, priority = 250 },
  }),
})

vim.keymap.set("n", "<C-c>", '"+yy', { desc = "Copy Line to Clipboard", silent = true })
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy Selection to Clipboard", silent = true })
vim.keymap.set({ "n", "v" }, "<C-v>", '"+p', { desc = "Paste from Clipboard" })

vim.keymap.set("n", "<leader>s", ":w<CR>", { desc = "Save File" })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a")

vim.keymap.set("n", "<leader>h", ":split<CR>", { desc = "Horizontal Split" })
vim.keymap.set("n", "<leader>v", ":vsplit<CR>", { desc = "Vertical Split" })

vim.keymap.set("n", "<M-h>", "<C-w>h", { desc = "Go to Left Split" })
vim.keymap.set("n", "<M-j>", "<C-w>j", { desc = "Go to Bottom Split" })
vim.keymap.set("n", "<M-k>", "<C-w>k", { desc = "Go to Top Split" })
vim.keymap.set("n", "<M-l>", "<C-w>l", { desc = "Go to Right Split" })

vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })

vim.keymap.set("n", "<leader>sr", function() require("spectre").open() end, { desc = "Search & Replace (Spectre)" })
vim.keymap.set("n", "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, { desc = "Search Word" })
vim.keymap.set("v", "<leader>sw", function() require("spectre").open_visual() end, { desc = "Search Selection" })

vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", ":qa!<CR>", { desc = "Force Quit All" })

local tb = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", tb.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", tb.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", tb.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fr", tb.oldfiles, { desc = "Recent Files" })
vim.keymap.set("n", "<leader>fd", tb.diagnostics, { desc = "Diagnostics" })

vim.keymap.set("n", "<leader>g", ":terminal lazygit<CR>", { desc = "LazyGit Terminal" })

vim.keymap.set("n", "<leader>aa", "<cmd>Codeium Auth<CR>", { desc = "Codeium Auth" })
vim.keymap.set("n", "<leader>at", "<cmd>Codeium Toggle<CR>", { desc = "Codeium Toggle" })
vim.keymap.set("i", "<C-g>", function() return vim.fn["codeium#Accept"]() end, { expr = true, desc = "Codeium Accept" })
vim.keymap.set("i", "<C-x>", function() return vim.fn["codeium#Clear"]() end, { expr = true, desc = "Codeium Dismiss" })

vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { silent = true })
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "G", "Gzz")

vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "p", '"_dP')

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename", buffer = true })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action", buffer = true })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover", buffer = true })

vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<CR>", { desc = "Find TODOs" })

vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>ba", ":%bdelete|edit#|bdelete#<CR>", { desc = "Delete Other Buffers" })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
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
    "checkhealth",
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
    end, 500)
  end,
})

print("Neovim Ready - 4GB RAM Optimized - Simple Keybinds - Clean UI")
