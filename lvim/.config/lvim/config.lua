-- General
local path_to_mason = "/home/jweissen/.local/share/lvim/mason/"

-- LSP
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "jdtls" })

-- Java
local path_to_jdtls = path_to_mason .. "packages/jdtls/"
-- Fix lombok notation processing problem

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

-- TypeScript
local tsserver_opts = {
  init_options = {
    plugins = {
      {
        name = '@vue/typescript-plugin',
        location = '/home/jweissen/Software/npm-deps/node_modules/@vue/typescript-plugin/',
        languages = { 'javascript', 'typescript', 'vue' },
      },
    },
  },
  filetypes = {
    "typescript", "javascript", "vue"
  }
}
require("lvim.lsp.manager").setup("tsserver", tsserver_opts)

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
