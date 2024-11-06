local status_ok, configs = pcall(require, "vscode.colors")
if not status_ok then
	return
end

local c = configs.get_colors()
vim.o.background = 'dark'
require('vscode').setup({
    -- Alternatively set style in setup
    -- style = 'light'

    -- Enable transparent background
    transparent = true,

    -- Enable italic comment
    italic_comments = true,

    -- Disable nvim-tree background color
    disable_nvimtree_bg = true,

    -- Override colors (see ./lua/vscode/colors.lua)
    -- color_overrides = {
    --     vscLineNumber = '#FFFFFF',
    -- },

    -- -- Override highlight groups (see ./lua/vscode/theme.lua)
    -- group_overrides = {
    --     -- this supports the same val table as vim.api.nvim_set_hl
    --     -- use colors from this colorscheme by requiring vscode.colors!
    --     Cursor = { fg=c.vscDarkBlue, bg=c.vscLightGreen, bold=true },
    -- }
})
require('vscode').load()

local fn = vim.fn

function get_color(group, attr)
    return fn.synIDattr(fn.synIDtrans(fn.hlID(group)), attr)
end

print(get_color("Normal", "bg#"))
