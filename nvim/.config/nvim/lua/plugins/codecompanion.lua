return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "hrsh7th/nvim-cmp",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("codecompanion").setup({
      strategies = {
        chat = {
          adapter = "copilot",
        },
        inline = {
          adapter = "copilot",
        },
        agent = {
          adapter = "copilot",
        },
      },
      adapters = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                default = "gpt-4.1",
              },
            },
          })
        end,
      },
      opts = {
        log_level = "INFO",
        send_code = true,
        use_default_actions = true,
        use_default_prompts = true,
      },
      display = {
        action_palette = {
          provider = "fzf_lua",
        },
        chat = {
          window = {
            layout = "vertical",
            position = "right",
            width = 0.3,
            height = 0.8,
          },
          show_settings = true,
          show_token_count = true,
        },
      },
    })

    vim.keymap.set("n", "<leader>aa", "<cmd>CodeCompanionChat<CR>", { desc = "New chat" })
    vim.keymap.set("n", "<leader>ap", "<cmd>CodeCompanionActions<CR>", { desc = "CodeCompanion Actions" })
  end,
}
