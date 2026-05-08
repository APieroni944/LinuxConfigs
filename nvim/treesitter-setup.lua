-- Configuration for nvim-treesitter
local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then return end

configs.setup({
  -- Install core parsers
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "javascript", "typescript", "rust" },
  sync_install = false,
  auto_install = true, -- Automatically install missing parsers
  highlight = { enable = true }, -- Enable syntax highlighting
  indent = { enable = true },    -- Enable indentation
})

