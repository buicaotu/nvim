return {
  scope = {
    keys = {
      textobject = {
        is = {
          min_size = 2, -- minimum size of the scope
          edge = false, -- inner scope
          cursor = false,
          treesitter = { blocks = { enabled = false } },
          desc = "inner scope",
        },
        as = {
          cursor = false,
          min_size = 2, -- minimum size of the scope
          treesitter = { blocks = { enabled = false } },
          desc = "full scope",
        },
      },
      jump = {
        ["[s"] = {
          min_size = 1, -- allow single line scopes
          bottom = false,
          cursor = false,
          edge = true,
          treesitter = { blocks = { enabled = false } },
          desc = "jump to top edge of scope",
        },
        ["]s"] = {
          min_size = 1, -- allow single line scopes
          bottom = true,
          cursor = false,
          edge = true,
          treesitter = { blocks = { enabled = false } },
          desc = "jump to bottom edge of scope",
        },
      },
    },
  }
} 