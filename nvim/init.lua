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
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",                        -- Autocompletions
  "https://github.com/nvim-lua/plenary.nvim",                   -- library dependency
  "https://github.com/nvim-tree/nvim-web-devicons",             -- icons (nerd font)
  "https://github.com/nvim-telescope/telescope.nvim",           -- Fuzzy finder
  "https://github.com/neovim/nvim-lspconfig",                   -- LSP configurations
  "https://github.com/mason-org/mason.nvim",                    -- LSP/Linter installer
  "https://github.com/mason-org/mason-lspconfig.nvim",          -- Mason-LSP bridge
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",-- Auto-install tools
  "https://github.com/EdenEast/nightfox.nvim",                  -- Nightfox theme
  "https://github.com/lervag/vimtex.git",                       -- VimTex 
  "https://github.com/nvim-tree/nvim-tree.lua.git",             -- File tree
}, { confirm = false })

-- ==========================================================================
-- SYNTAX & COMPLETION CONFIGURATION
-- ==========================================================================

--MINI.NVIM 

--vim.opt.completeopt = { "menuone", "noselect", "noinsert" }

-- 3. Plugin Configuration
--require('mini.completion').setup({
  --lsp_completion = {
    -- Filter results before they are displayed
    --process_items = function(items, base)
      -- Keep only the top 5 items
      --if #items > 5 then
        --items = vim.list_slice(items, 1, 5)
      --end
      -- Return with default processing (for icons and snippets)
      --return MiniCompletion.default_process_items(items, base)
    --end,
  --},
--})

-- BLINK.CMP

--vim.g.blink_cmp_building = false

require("blink.cmp").setup({
  fuzzy = { 
    implementation = "prefer_rust",
    --prebuilt_binaries = { 
      --download = false, 
      --ignore_version_mismatch = true 
    --},
  },
  -- Custom keymap settings
  keymap = {
    preset = 'enter',
    --["<Right>"] = { "cancel", "fallback" },
    --["<CR>"] = { "accept", "fallback" },
  },
  completion = {
    list = {
      selection = {
        preselect = false,
        --auto_insert = false,
      },
    },
  },
})

-- ==========================================================================
-- FILE FUZZY FINDER
-- ==========================================================================

--require('mini.pick').setup({
  --window = {
    --config = function()
      -- 1. Define how big you want the window to be
      --local height = 15
      --local width = 60
      -- 2. Calculate the exact center
      --return {
        --relative = 'editor',
        --anchor = 'NW',
        --height = height,
        --width = width,
        --row = math.floor(0.5 * (vim.o.lines - height)),
        --col = math.floor(0.5 * (vim.o.columns - width)),
        --border = 'rounded', -- Floating box with nice corners
      --}
    --end,
  --},
  --mappings = {
    --stop = '<Esc>', -- Single press Esc to exit the overlay
  --},
--})

--vim.api.nvim_create_autocmd("VimEnter", {
  --callback = function()
    -- Only set the mapping if nvim started empty (the welcome screen)
    --if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == "" then
      -- map Space ONLY for this specific start buffer
      --vim.keymap.set('n', '<Space>', function()
      --require('mini.pick').builtin.files()
      --end, { buffer = true, desc = "Open search from welcome screen" })
    --end
  --end,
--})

--vim.keymap.set('n', '<M-e>', '<cmd>Pick files<cr>', { desc = "Open File Picker" })

require('telescope').setup({
  defaults = {
    layout_strategy = 'horizontal', -- Puts file list on left, preview on right
    layout_config = {
      width = 0.70,                 -- Makes the whole window take up 90% of your screen
      preview_width = 0.50,         -- Gives 60% of that space to the preview box
    },
  },
})

vim.keymap.set('n', '<M-e>', require('telescope.builtin').find_files, { desc = 'Open Telescope File Picker' })

-- Open Telescope automatically if Neovim is opened without a file
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Check if the current buffer is completely empty and unnamed
    if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == "" then
      -- Trigger your preferred Telescope picker (e.g., find_files)
      require('telescope.builtin').find_files()
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

vim.diagnostic.config({
  virtual_text = false, -- Turns off the text at the end of the line
  underline = true,    -- Keeps the underline under the error/warning
  signs = true,        -- Keeps the icon in the left gutter (optional)
})

vim.api.nvim_create_autocmd("CursorHold", {
  buffer = bufnr,
  callback = function()
    local opts = {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = 'rounded',
      source = 'always',
      prefix = ' ',
      scope = 'cursor',
    }
    vim.diagnostic.open_float(nil, opts)
  end,
})


-- ==========================================================================
-- FILE TREE
-- ==========================================================================

require('nvim-tree').setup({})

vim.keymap.set('n', '<M-->', ':NvimTreeToggle<CR>', { silent = true, desc = 'Toggle File Tree' })

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


