return {
  provider = "copilot",
  auto_suggestions_provider = "copilot",
  -- openai = {
  --   api_key_name = {"op", "read", "op://Private/OpenAI-Canva/credential"},
  -- },
  file_selector = {
    provider = "fzf",
    provider_opts = {
      ---@param params avante.file_selector.opts.IGetFilepathsParams
      get_filepaths = function(params)
        local cwd = params.cwd ---@type string
        local selected_filepaths = params.selected_filepaths ---@type string[]
        local cmd = string.format("fd --base-directory '%s' --hidden", vim.fn.fnameescape(cwd))
        local output = vim.fn.system(cmd)
        local filepaths = vim.split(output, "\n", { trimempty = true })
        return vim
          .iter(filepaths)
          :filter(function(filepath)
            return not vim.tbl_contains(selected_filepaths, filepath)
          end)
          :totable()
      end
    }
  },
  mappings = {
    ask = "<leader>aa", -- ask
    edit = "<leader>ae", -- edit
    refresh = "<leader>ar", -- refresh
  },
} 