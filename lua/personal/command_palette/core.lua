local M = {}

-- Store commands in a table
M.commands = {}

-- Store command history
M.command_history = {}
-- Track grep commands in command_history
local grep_count = 0

-- Function to add a command to history
function M.add_to_history(command)
  local is_grep = command.description:match("^grep:")
  
  -- Remove if already in history
  for i, cmd in ipairs(M.command_history) do
    if cmd.description == command.description then
      -- If this is a grep command, reduce the count
      if is_grep then
        grep_count = grep_count - 1
      end
      table.remove(M.command_history, i)
      break
    end
  end
  
  -- Add to the beginning of history
  table.insert(M.command_history, 1, command)
  
  -- Increase grep count if this is a grep command
  if is_grep then
    grep_count = grep_count + 1
    
    -- Limit to 5 grep commands
    if grep_count > 5 then
      -- Find the oldest grep command and remove it
      for i = #M.command_history, 1, -1 do
        if M.command_history[i].description:match("^grep:") then
          table.remove(M.command_history, i)
          grep_count = grep_count - 1
          break
        end
      end
    end
  end
end

-- Function to execute a command
function M.execute_command(command)
  M.add_to_history(command)
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
                M.execute_command(cmd)
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

return M 