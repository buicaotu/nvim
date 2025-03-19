local M = {}

local function get_git_root()
  local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
  if not handle then return nil end
  
  local result = handle:read("*l")
  local success = handle:close()
  
  if not success or not result or result == "" then
    return nil
  end
  
  return result
end

function M.setup()
  local git_root = get_git_root()
  if git_root then
    local dprint_dir = vim.fn.fnamemodify(git_root .. "/tools/dprint", ":p")
    if vim.fn.isdirectory(dprint_dir) == 1 then
      vim.g.dprint_dir = dprint_dir
      vim.g.dprint_format_on_save = 1 
      vim.g.dprint_system_command = 'Dispatch'
      vim.g.dprint_debug = 0
    end
  end
end

return M 