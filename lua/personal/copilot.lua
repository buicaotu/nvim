local status_ok, copilot_chat = pcall(require, "CopilotChat")
if not status_ok then
  return
end

copilot_chat.setup({
  mappings = {
    reset = {
      normal = '<leader>cr',
      insert = '<leader>cr'
    },
  },
})
