local status_ok, lsp_zero = pcall(require, "lsp-zero")
if not status_ok then
  return
end

local lspformat = require('lsp-format')
lspformat.setup({})

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({ buffer = bufnr })

  -- format on save -- SYNC
  -- lsp_zero.buffer_autoformat()

  -- format on save -- ASYNC
  -- make sure you use clients with formatting capabilities
  -- otherwise you'll get a warning message
  -- if client.supports_method('textDocument/formatting') then
  --   lspformat.on_attach(client)
  -- end
end)

require('mason').setup({})
require("mason-lspconfig").setup({
  ensure_installed = { "ts_ls", "eslint", "efm" },
  automatic_installation = false,
  handlers = {
    lsp_zero.default_setup,
  },
})

local lspconfig = require('lspconfig')

lspconfig.eslint.setup({
  -- codeActionOnSave = {
  --   enable = true,
  --   mode = "all"
  -- },
  on_attach = function(client, bufnr)
    -- todo use init_options?
    client.server_capabilities.documentFormattingProvider = false
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
})

lspconfig.ts_ls.setup({
  init_options = {
    preferences = {
      -- includeInlayParameterNameHints = 'all',
      -- includeInlayParameterNameHintsWhenArgumentMatchesName = true,
      -- includeInlayFunctionParameterTypeHints = true,
      -- includeInlayVariableTypeHints = true,
      -- includeInlayPropertyDeclarationTypeHints = true,
      -- includeInlayFunctionLikeReturnTypeHints = true,
      -- includeInlayEnumMemberValueHints = true,
      -- importModuleSpecifierPreference = 'non-relative',
      includeInlayParameterNameHints = 'all', -- 'none' | 'literals' | 'all';
      includeInlayParameterNameHintsWhenArgumentMatchesName = true,
      includeInlayFunctionParameterTypeHints = true,
      includeInlayVariableTypeHints = true,
      includeInlayVariableTypeHintsWhenTypeMatchesName = true,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = true,
      includeInlayEnumMemberValueHints = true,
    },
  },
  on_attach = function(client, bufnr)
    -- dont use tsserver to format
    -- todo use init_options?
    client.server_capabilities.documentFormattingProvider = false
  end
})

local prettier = {
  formatCommand = "./node_modules/.bin/prettier --stdin-filepath ${INPUT}",
  formatStdin = true,
}
local prettier_work = {
  formatCommand = "./web/node_modules/.bin/prettier --stdin-filepath ${INPUT}",
  formatStdin = true,
}
local dprint = {
  formatCommand = "./tools/dprint/dprint fmt -- ${INPUT}",
  formatStdin = false,
}
local dprint_stdin = {
  formatCommand = "./tools/dprint/dprint fmt --stdin ${INPUT}",
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
  on_attach = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_command('autocmd BufWritePre <buffer> lua vim.lsp.buf.format()')
    end
  end,
}

local cmp = require('cmp')
-- local luasnip = require('luasnip')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
  },

  -- always select first item
  preselect = 'item',
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },

  mapping = cmp.mapping.preset.insert({

    -- ["<Tab>"] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_next_item()
    --   elseif luasnip.expand_or_jumpable() then
    --     luasnip.expand_or_jump()
    --   -- elseif has_words_before() then
    --   --   cmp.complete()
    --   else
    --     fallback()
    --   end
    -- end, { "i", "s" }),

    -- ["<S-Tab>"] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_prev_item()
    --   elseif luasnip.jumpable(-1) then
    --     luasnip.jump(-1)
    --   else
    --     fallback()
    --   end
    -- end, { "i", "s" }),

    ['<Tab>'] = cmp_action.luasnip_supertab(),
    ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
    -- `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({ select = false }),

    -- Ctrl+Space to trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),

    -- Navigate between snippet placeholder
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),

    -- Scroll up and down in the completion documentation
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  })
})

-- local has_words_before = function()
--   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
--   return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
-- end
