local status_ok, dapui = pcall(require, "dapui")
if not status_ok then
	return
end

dapui.setup();

local dap = require"dap"
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open({})
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close({})
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close({})
end

vim.keymap.set('n', '<leader>du', require 'dapui'.toggle)
