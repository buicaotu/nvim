local opts = { noremap = true, silent = true, nowait = true }

local status_ok, Job = pcall(require, 'plenary.job')
if not status_ok then
  return
end

-- Save and run this file
vim.api.nvim_create_user_command('SS', function()
    vim.cmd(':w')
    local file_path = vim.fn.expand('%')
    vim.cmd('source ' .. file_path)
    print('source file ' .. file_path)
  end, {})
vim.api.nvim_create_user_command('EditNvimConfig', function()
    vim.cmd('e ~/.config/nvim')
  end, {})

function P(obj)
  print(vim.inspect(obj))
end

-- Git workflow
local function find_merge_base(base_branch)
  base_branch = base_branch ~= nil and base_branch or 'master'
  local commit = nil
  Job:new({
    command = 'git',
    args = { 'merge-base', 'origin/' .. base_branch, 'h' },
    on_stdout = function(err, data)
      if err == nil and data ~= nil then
        commit = data
        return
      end
      error('git commit not found ' .. err)
    end,
  }):sync()
  return commit
end

local function git_diff(commit)
  local list = nil
  Job:new({
    command = 'git',
    args = { 'diff', commit, '--relative', '--name-only' },
    on_exit = function(job, code)
      if code == 0 then
        list = job:result()
        return
      end
      error('git diff error ' .. code)
    end
  }):sync(15000)
  return list
end

-- find a base commit and perform diff and save it to the quickfix list
local current_commit = nil
local function diff_branch(base_branch)
  local commit = find_merge_base(base_branch)
  current_commit = commit
  local list = git_diff(current_commit)
  local qflist = {}
  for i, v in ipairs(list) do
    qflist[i] = {
      filename = v,
      lnum = 1,
    }
  end
  local result = vim.fn.setqflist({}, ' ', {
    title = 'Diff ' .. base_branch,
    items = qflist
  })
  if result == 0 then
    vim.cmd('copen')
  else
    error('failed to set qflist with diff result' .. result)
  end
end

local function diff_branch_factory(base_branch)
  return function ()
    diff_branch(base_branch)
  end
end

vim.api.nvim_create_user_command('DiffGreen', diff_branch_factory('green'), {})
vim.api.nvim_create_user_command('DiffMaster', diff_branch_factory('master'), {})

vim.keymap.set('n', '<leader>dg', function()
  vim.cmd('Gvdiffsplit ' .. current_commit .. ':%')
end, opts)

vim.api.nvim_create_user_command('Wa', ':wa', {})

-- 
