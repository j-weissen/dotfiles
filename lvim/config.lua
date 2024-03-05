-- General
local path_to_mason = "/home/jweissen/.local/share/lvim/mason/"

-- Java
local path_to_jdtls = path_to_mason .. "packages/jdtls/"
-- Fix lombok notation processing problem
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "jdtls" })

local jdtls_opts = {
  cmd = {
    path_to_mason .. "bin/jdtls",
    "--jvm-arg=-javaagent:" .. path_to_jdtls .. "lombok.jar",
    "-configuration",
    "/home/jweissen/.cache/jdtls/config",
    "-data",
    "/home/jweissen/.cache/jdtls/workspace"
  }
}
require("lvim.lsp.manager").setup("jdtls", jdtls_opts)

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  {
    command = "prettier",
    filetypes = { "typescript", "vue" },
  },
}

lvim.format_on_save.enabled = true

-- Plugins
lvim.plugins = {
  { 'akinsho/toggleterm.nvim', version = "*", config = true }
}

require("toggleterm").setup {
  open_mapping = '<C-g>',
  direction = 'horizontal',
  shade_terminals = true,
  dir = "$(pwd)",
}
