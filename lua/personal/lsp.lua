local lspconfig = require('lspconfig')
local lspformat = require('lsp-format')
lspformat.setup({})

-- Add cmp_nvim_lsp capabilities settings to lspconfig
-- This should be executed before you configure any language server
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    -- Keymaps
    local opts = { noremap = true, silent = true, buffer = event.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', 'gl', vim.diagnostic.open_float, opts)
    -- vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    -- vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    -- vim.keymap.set('n', '<leader>wl', function()
    --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end
})

-- Setup mason
require('mason').setup({})
require("mason-lspconfig").setup({
  ensure_installed = { "ts_ls", "eslint", "efm" },
  automatic_installation = false,
})

lspconfig.eslint.setup({
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
})

lspconfig.denols.setup({
  root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
  init_options = {
    enable = true,
    lint = true,
    unstable = false,
    importMap = "./deno.json"
  }
})

lspconfig.ts_ls.setup({
  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = false
  end,
  single_file_support = false,
  root_dir = lspconfig.util.root_pattern("package.json"),
  init_options = {
    preferences = {
      includeInlayParameterNameHints = 'all',
      includeInlayParameterNameHintsWhenArgumentMatchesName = true,
      includeInlayFunctionParameterTypeHints = true,
      includeInlayVariableTypeHints = true,
      includeInlayVariableTypeHintsWhenTypeMatchesName = true,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = true,
      includeInlayEnumMemberValueHints = true,
    },
  },
})

local prettier = {
  formatCommand = "./node_modules/.bin/prettier --stdin-filepath ${INPUT}",
  formatStdin = true,
}
local prettier_work = {
  formatCommand = "./web/node_modules/.bin/prettier --stdin-filepath ${INPUT}",
  formatStdin = true,
}

local web_formatter = prettier
local work_dir = vim.fn.getcwd():find(vim.fn.expand("~") .. "/work") == 1
if work_dir then
  web_formatter = prettier_work
else
  web_formatter = prettier
end

-- Set up efm-langserver
lspconfig.efm.setup {
  on_attach = function(client)
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_command('autocmd BufWritePre <buffer> lua vim.lsp.buf.format()')
    end
  end,
  init_options = { documentFormatting = not work_dir },
  root_dir = function(fname)
    return lspconfig.util.root_pattern('.prettierrc', '.prettierrc.js', '.git')(fname) or vim.loop.cwd()
  end,
  settings = {
    rootMarkers = {".prettierrc", ".prettierrc.js", "dprint.json"},
    languages = {
      javascript = {web_formatter},
      typescript = {web_formatter},
      javascriptreact = {web_formatter},
      typescriptreact = {web_formatter},
      html = {web_formatter},
      markdown = {web_formatter},
      json = {web_formatter},
    },
  },
  filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  timeout_ms = 10000,
}

lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = { library = vim.api.nvim_get_runtime_file('', true) },
      telemetry = { enable = false },
    },
  },
})

-- Diagnostic navigation with repeat support
local ts_repeat_move_status, ts_repeat_move = pcall(require, "nvim-treesitter.textobjects.repeatable_move")
if ts_repeat_move_status then
  -- Register the diagnostic navigation functions with repeatable_move
  local next_diagnostic, prev_diagnostic = ts_repeat_move.make_repeatable_move_pair(
    vim.diagnostic.goto_next,
    vim.diagnostic.goto_prev
  )

  -- Map the diagnostic navigation to use repeatable_move
  vim.keymap.set('n', ']d', next_diagnostic, { noremap = true, silent = true })
  vim.keymap.set('n', '[d', prev_diagnostic, { noremap = true, silent = true })
end
