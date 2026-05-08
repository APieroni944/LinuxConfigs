-- ==========================================================================
-- UI & EDITOR SETTINGS
-- ==========================================================================

-- Enable hybrid line numbers: absolute for current line, relative for others
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

-- Keep the gutter (for signs/icons) open to prevent text jumping
vim.opt.signcolumn = "yes"

-- Indentation settings: 2 spaces per tab, convert tabs to spaces
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Show LSP diagnostics (errors/warnings) inline next to the code
vim.diagnostic.config({ virtual_text = true })

-- Set to use system clipboard
vim.opt.clipboard = "unnamedplus"

-- ==========================================================================
-- PLUGIN MANAGEMENT
-- ==========================================================================

-- Download and register plugins using Neovim's built-in package system
vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",         -- Better highlighting
  "https://github.com/echasnovski/mini.nvim",                   -- Autocompletions
  "https://github.com/nvim-mini/mini.pick.git",                 -- Fuzzy finder
  "https://github.com/neovim/nvim-lspconfig",                   -- LSP configurations
  "https://github.com/mason-org/mason.nvim",                    -- LSP/Linter installer
  "https://github.com/mason-org/mason-lspconfig.nvim",          -- Mason-LSP bridge
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",-- Auto-install tools
  "https://github.com/EdenEast/nightfox.nvim",                  -- Nightfox theme
  "https://github.com/lervag/vimtex.git",                       -- VimTex 
}, { confirm = false })

-- ==========================================================================
-- SYNTAX & COMPLETION CONFIGURATION
-- ==========================================================================

vim.opt.completeopt = { "menuone", "noselect", "noinsert" }

-- 3. Plugin Configuration
require('mini.completion').setup({
  delay = { completion = 200, info = 100 },
  lsp_completion = {
    source_func = 'completefunc',
    auto_setup = true,
  },
  window = {
    info = { border = 'rounded' },
  },
})

-- ==========================================================================
-- FILE FUZZY FINDER
-- ==========================================================================

require('mini.pick').setup({
  window = {
    config = function()
      -- 1. Define how big you want the window to be
      local height = 15
      local width = 60
      -- 2. Calculate the exact center
      return {
        relative = 'editor',
        anchor = 'NW',
        height = height,
        width = width,
        row = math.floor(0.5 * (vim.o.lines - height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
        border = 'rounded', -- Floating box with nice corners
      }
    end,
  },
  mappings = {
    stop = '<Esc>', -- Single press Esc to exit the overlay
  },
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Only set the mapping if nvim started empty (the welcome screen)
    if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == "" then
      -- map Space ONLY for this specific start buffer
      vim.keymap.set('n', '<Space>', function()
        require('mini.pick').builtin.files()
      end, { buffer = true, desc = "Open search from welcome screen" })
    end
  end,
})


-- ==========================================================================
-- LSP (LANGUAGE SERVER PROTOCOL) SETUP
-- ==========================================================================

-- Define which servers to use and their specific settings
local lsp_servers = {
  -- Configure Lua server to recognize Neovim's built-in functions
  lua_ls = {
    Lua = {
      workspace = { library = vim.api.nvim_get_runtime_file("lua", true) }
    }
  },
}

-- Initialize Mason and its helper plugins
require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
  -- Automatically install any server defined in the 'lsp_servers' table above
  ensure_installed = vim.tbl_keys(lsp_servers),
})

-- Loop through our servers and apply the configurations to Neovim
for server, config in pairs(lsp_servers) do
  vim.lsp.config(server, {
    settings = config,

    -- Define shortcuts that only work when a Language Server is active
    on_attach = function(_, bufnr)
      -- 'grd' = Go to Definition
      vim.keymap.set("n", "grd", vim.lsp.buf.definition, { buffer = bufnr })
    end,
  })
end


-- ==========================================================================
-- VISUAL CONFIG 
-- ==========================================================================

-- Set the visual theme
vim.cmd.colorscheme("carbonfox")

vim.api.nvim_set_hl(0, "LineNr", { fg = "#ffffff" })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#00ffff", bold = true })
vim.api.nvim_set_hl(0, "Comment", { fg = "#757575", italic = true })

vim.opt.wrap = true          -- Enable soft wrapping
vim.opt.linebreak = true     -- Wrap at whole words rather than mid-word
vim.opt.breakindent = true   -- Maintain indentation on wrapped lines

-- ==========================================================================
-- MISC CONFIG  
-- ==========================================================================

vim.g.tex_flavor = 'latex'


