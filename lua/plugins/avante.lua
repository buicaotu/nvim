return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false,
  opts = {
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
  },
  build = "make",
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-tree/nvim-web-devicons",
    "github/copilot.vim",
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          use_absolute_path = true,
        },
      },
    },
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
} 