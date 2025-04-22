local M = {}

-- Store commands in a table
M.commands = {
  {
    description = "lsp: restart language server",
    action = ":LspRestart"
  },
  {
    description = "workflow: diff green",
    action = ":DiffGreen"
  },
  {
    description = "buffer: close all other buffers",
    action = function()
      local current_buf = vim.api.nvim_get_current_buf()
      -- Get all buffer numbers
      local buffers = vim.api.nvim_list_bufs()
      for _, buf in ipairs(buffers) do
        -- Skip current buffer
        if buf ~= current_buf then
          -- Skip terminal buffers
          local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
          if buftype ~= "terminal" then
            -- Check if buffer is modified
            local is_modified = vim.api.nvim_buf_get_option(buf, "modified")
            if is_modified then
              -- Get buffer name for the prompt
              local bufname = vim.api.nvim_buf_get_name(buf)
              bufname = bufname ~= "" and bufname or "[No Name]"
              -- Prompt to save
              local choice = vim.fn.confirm("Save changes to " .. bufname .. "?", "&Yes\n&No\n&Cancel", 1)
              if choice == 1 then -- Yes
                vim.api.nvim_buf_call(buf, function() vim.cmd("silent! w") end)
                vim.api.nvim_buf_delete(buf, {})
              elseif choice == 2 then -- No
                vim.api.nvim_buf_delete(buf, { force = true })
              elseif choice == 3 then -- Cancel
                return -- Stop the process
              end
            else
              -- Not modified, just delete
              vim.api.nvim_buf_delete(buf, {})
            end
          end
        end
      end
    end
  },
}

-- Store command history
M.command_history = {}

-- Function to add a command to history
local function add_to_history(command)
  -- Remove if already in history
  for i, cmd in ipairs(M.command_history) do
    if cmd.description == command.description then
      table.remove(M.command_history, i)
      break
    end
  end
  -- Add to the beginning of history
  table.insert(M.command_history, 1, command)
end

-- Function to execute a command
local function execute_command(command)
  add_to_history(command)
  if type(command.action) == "function" then
    command.action()
  elseif type(command.action) == "string" and command.action:sub(1, 1) == ":" then
    vim.cmd(command.action:sub(2))
  else
    vim.cmd(command.action)
  end
end

-- Function to open the command palette
function M.open_palette()
  -- Combine history and commands, removing duplicates
  local display_commands = {}
  local seen = {}
  -- First add history items
  for _, cmd in ipairs(M.command_history) do
    if not seen[cmd.description] then
      table.insert(display_commands, cmd)
      seen[cmd.description] = true
    end
  end
  -- Then add remaining commands
  for _, cmd in ipairs(M.commands) do
    if not seen[cmd.description] then
      table.insert(display_commands, cmd)
      seen[cmd.description] = true
    end
  end
  -- Create display strings for fzf-lua
  local display_strings = {}
  for _, cmd in ipairs(display_commands) do
    table.insert(display_strings, cmd.description)
  end
  -- Display command palette using fzf-lua
  require("fzf-lua").fzf_exec(
    display_strings,
    {
      prompt = "Command Palette> ",
      actions = {
        ["default"] = function(selected)
          if #selected > 0 then
            local selected_description = selected[1]
            -- Find the command with this description
            for _, cmd in ipairs(display_commands) do
              if cmd.description == selected_description then
                execute_command(cmd)
                break
              end
            end
          end
        end
      }
    }
  )
end

-- Function to register a new command
function M.register_command(description, action)
  table.insert(M.commands, {
    description = description,
    action = action
  })
end

-- Setup function (no longer sets keymap)
function M.setup()
  -- No longer setting keymap here as it's handled by lazy.nvim
end

return M
