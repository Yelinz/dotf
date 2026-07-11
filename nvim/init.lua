-- Basic editor preferences
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.hlsearch = false
vim.o.mouse = 'a'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300
vim.o.termguicolors = true
vim.o.completeopt = 'menuone,noselect'

vim.wo.number = true
vim.wo.signcolumn = 'yes'

vim.opt.smartindent = true
vim.opt.clipboard = 'unnamedplus'

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  virtual_text = {
    prefix = '●',
    spacing = 2,
  },
  float = {
    border = 'rounded',
    source = 'if_many',
  },
})

for type, icon in pairs({ Error = '', Warn = '', Hint = '󰌶', Info = '' }) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

local function lsp_map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, buffer = true, desc = desc })
end

require('lazy').setup({
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('catppuccin-mocha')
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPre', 'BufNewFile' },
    build = ':TSUpdate',
    opts = {
      ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'query', 'python', 'css', 'javascript', 'html', 'json', 'bash', 'markdown' },
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
      autotag = { enable = true },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    version = false,
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {},
  },
  'tpope/vim-sleuth',
})

local lsp_group = vim.api.nvim_create_augroup('dotf-lsp', { clear = true })

vim.api.nvim_create_autocmd('LspAttach', {
  group = lsp_group,
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }

    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    lsp_map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
    lsp_map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
    lsp_map('n', 'gr', vim.lsp.buf.references, 'Go to references')
    lsp_map('n', 'gi', vim.lsp.buf.implementation, 'Go to implementation')
    lsp_map('n', 'K', vim.lsp.buf.hover, 'Hover docs')
    lsp_map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
    lsp_map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code action')
    lsp_map('n', '<leader>f', function()
      vim.lsp.buf.format({ async = true })
    end, 'Format buffer')
    lsp_map('n', '<leader>e', function()
      vim.diagnostic.open_float(nil, { focus = false, scope = 'line' })
    end, 'Line diagnostics')
    lsp_map('n', '[d', vim.diagnostic.goto_prev, 'Previous diagnostic')
    lsp_map('n', ']d', vim.diagnostic.goto_next, 'Next diagnostic')

    -- Preserve a couple of generic maps that are handy even without LSP.
    vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', vim.tbl_extend('force', opts, { desc = 'Diagnostics' }))
  end,
})

if vim.lsp.config and vim.lsp.enable then
  vim.lsp.config('lua_ls', {
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' },
        },
        workspace = {
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  })
  vim.lsp.enable('lua_ls')
else
  local lspconfig = require('lspconfig')
  lspconfig.lua_ls.setup({
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' },
        },
        workspace = {
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  })
end

map('n', '<leader>ff', function()
  require('telescope.builtin').find_files()
end, 'Find files')
map('n', '<leader>fg', function()
  require('telescope.builtin').live_grep()
end, 'Live grep')
map('n', '<leader>fb', function()
  require('telescope.builtin').buffers()
end, 'Buffers')
map('n', '<leader>fh', function()
  require('telescope.builtin').help_tags()
end, 'Help tags')