
return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    "fzf-vim",
    winopts = {
      preview = { hidden = "nohidden" },
    },
    files = {
      -- disable previewer for file search only
      previewer = false,
      git_icons = false,
    },
    buffers = {
      previewer = false,
      git_icons = false,
    },
    oldfiles = {
      previewer = false,
    },
    previewers = {
      syntax_limit_b = 1024 * 100, -- 100KB
    }
  }
}
