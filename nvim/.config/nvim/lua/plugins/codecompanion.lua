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
                default = "gpt-4",
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
          provider = "fzf",
        },
        chat = {
          window = {
            layout = "vertical",
            width = 0.45,
            height = 0.8,
          },
          show_settings = true,
          show_token_count = true,
        },
      },
      keymaps = {
        ["<leader>aa"] = {
          modes = { "n", "v" },
          callback = "strategies.chat.new",
          description = "New chat",
        },
        ["<leader>ae"] = {
          modes = { "v" },
          callback = "strategies.inline.start",
          description = "Inline assistant",
        },
        ["<leader>ar"] = {
          modes = { "n" },
          callback = function()
            require("codecompanion").setup({})
          end,
          description = "Refresh CodeCompanion",
        },
      },
    })
  end,
} 