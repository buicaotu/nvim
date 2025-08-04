local ns_id = vim.api.nvim_create_namespace("git_conflict_highlight")

local function highlight_conflict_markers()
  print('Highlighting conflict markers...')
  local bufnr = vim.api.nvim_get_current_buf()

  -- Clear previous extmarks
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  local has_conflict = false
  local current_line = 1
  local last_line = vim.api.nvim_buf_line_count(bufnr)

  -- Save cursor position
  local save_cursor = vim.fn.getcurpos()

  while current_line <= last_line do
    -- Move to current line
    vim.fn.cursor(current_line, 1)

    -- Find start marker
    local start_line = vim.fn.search("^<<<<<<<", "nW")
    if start_line == 0 then
      break
    end

    print("Found conflict start at line: " .. start_line)

    -- Move to the start line and find separator marker from there
    vim.fn.cursor(start_line, 1)
    local separator_line = vim.fn.search("^=======", "nW")
    if separator_line == 0 or separator_line <= start_line then
      break
    end

    print("Found conflict separator at line: " .. separator_line)

    -- Move to the separator line and find end marker from there
    vim.fn.cursor(separator_line, 1)
    local end_line = vim.fn.search("^>>>>>>>", "nW")
    if end_line == 0 or end_line <= separator_line then
      break
    end

    print("Found conflict end at line: " .. end_line)

    has_conflict = true

    -- Get end column for the range
    -- local start_col = #vim.api.nvim_buf_get_lines(bufnr, start_line - 1, start_line, false)[1]
    local separator_col = #vim.api.nvim_buf_get_lines(bufnr, separator_line - 1, separator_line, false)[1]
    local end_col = #vim.api.nvim_buf_get_lines(bufnr, end_line - 1, end_line, false)[1]

    -- Highlight first section with light blue
    -- vim.api.nvim_buf_set_extmark(bufnr, ns_id, start_line - 1, 0, {
    --   end_line = separator_line - 1,
    --   end_col = separator_col,
    --   hl_group = "ConflictMarkerOurs",
    --   priority = 100
    -- })

    print('Highlighting conflict section from line ' .. separator_line + 1 .. ' to ' .. end_line - 1)
    -- Highlight second section with light green
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, separator_line, 0, {
      end_line = end_line,
      end_col = end_col,
      hl_group = "ConflictMarkerTheirs",
      priority = 100
    })

    -- Update position for next search
    current_line = end_line + 1
  end

  -- Restore cursor position
  vim.fn.setpos('.', save_cursor)

  print(has_conflict and " Conflicts found." or " No conflicts found.")
  return has_conflict
end

-- Define highlight groups if they don't exist
local function setup_highlights()
  vim.api.nvim_set_hl(0, "ConflictMarkerOurs", { bg = "#c2dfff" })   -- light blue
  vim.api.nvim_set_hl(0, "ConflictMarkerTheirs", { bg = "#c2ffc2" }) -- light green
end

local function setup()
  setup_highlights()

  -- Set up autocommands for conflict detection
  local group = vim.api.nvim_create_augroup("GitConflictHighlight", { clear = true })
  vim.api.nvim_create_autocmd({
    "BufReadPost",
    "FileChangedShellPost",
    "ShellFilterPost",
    "StdinReadPost"
  }, {
    group = group,
    callback = function()
      highlight_conflict_markers()
    end,
  })
end

return {
  setup = setup
}
