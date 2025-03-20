local lspconfig = require('lspconfig')
local lspformat = require('lsp-format')
lspformat.setup({})

-- Global capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.preselectSupport = true
capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
capabilities.textDocument.completion.completionItem.deprecatedSupport = true
capabilities.textDocument.completion.completionItem.preselectSupport = true
capabilities.textDocument.completion.completionItem.tagSupport = {
  valueSet = { 1 }
}
capabilities.textDocument.completion.completionItem.commitCharactersSupport = true

-- Global on_attach function
local on_attach = function(client, bufnr)
  -- Keymaps
  local opts = { noremap = true, silent = true, buffer = bufnr }
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

-- Setup mason
require('mason').setup({})
require("mason-lspconfig").setup({
  ensure_installed = { "ts_ls", "eslint", "efm" },
  automatic_installation = false,
})

lspconfig.eslint.setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
})

lspconfig.denols.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
  init_options = {
    enable = true,
    lint = true,
    unstable = false,
    importMap = "./deno.json" 
  }
})

lspconfig.ts_ls.setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
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
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
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

local cmp = require('cmp')
cmp.setup({
  sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
  },
  preselect = 'item',
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  })
})
