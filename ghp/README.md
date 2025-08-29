# ghp.nvim

A Neovim plugin for GitHub PR workflow integration.

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "username/ghp.nvim",
  config = function()
    require("ghp").setup({
      -- your configuration options here
    })
  end,
  dependencies = {
    -- This plugin requires the gh CLI to be installed on your system
  }
}
```

## Requirements

- [GitHub CLI](https://cli.github.com/) (`gh`) must be installed and authenticated

## Configuration

Default configuration:

```lua
{
  enabled = true,
  -- Add your configuration options here
}
```

## Usage

### Commands

#### GHPReview

```
:GHPReview
```

This command:
- Uses GitHub CLI to check if there is a PR associated with your current branch
- Loads all changed files in the PR into the quickfix list
- Sets the quickfix list title to "PR: [PR Title]"
- Stores the PR information and quickfix list in memory

#### GHPRestore

```
:GHPRestore [pr_number]
```

Restores a previously loaded PR quickfix list. If no PR number is provided, it restores the most recently viewed PR.

#### GHPReviewShow

```
:GHPReviewShow
```

Opens a floating window displaying information about the current PR being reviewed, including:
- PR title and number
- Branch name and commit hash
- PR URL
- List of changed files

Press `q` or `<Esc>` to close the floating window.

## License

MIT 