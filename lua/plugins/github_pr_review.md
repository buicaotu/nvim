# GitHub PR Review Plugin for Neovim

A Neovim plugin to review GitHub Pull Requests using the GitHub CLI (`gh`).

## Prerequisites

- GitHub CLI (`gh`) must be installed and authenticated
- You must be in a git repository with a PR associated with the current branch

## Features

- Load PR files into the quickfix list for quick navigation
- View PR information (title, author, state, review status)
- Open PR in browser
- View PR diff in a buffer
- Add comments to the PR
- Add file-specific comments at the current line
- View all comments on the PR
- Submit PR reviews (approve, request changes, comment)

## Commands

- `:PRReview` - Review the PR for the current branch and load file changes into quickfix list
- `:PROpen` - Open current PR in browser
- `:PRComment` - Add a comment to the current PR
- `:PRFileComment` - Add a comment to a specific file and line in the PR
- `:PRDiff` - View the full PR diff in a buffer
- `:PRComments` - View all comments on the PR
- `:PRSubmitReview` - Submit a review for the PR (approve, request changes, or comment)

## Keymaps

If you have which-key installed, the plugin registers keymaps under `<leader>gp`:

- `<leader>gpr` - Review current PR
- `<leader>gpo` - Open PR in browser
- `<leader>gpc` - Add PR comment
- `<leader>gpf` - Add file comment
- `<leader>gpd` - View PR diff
- `<leader>gpm` - View PR comments
- `<leader>gps` - Submit PR review

If which-key is not available, these keymaps are registered directly.

## Usage

1. Check out a branch that has an open PR
2. Run `:PRReview` to load the PR files into the quickfix list
3. Navigate through the files to review the changes
4. Use `:PRFileComment` on specific lines to add comments
5. Use `:PRComment` to add general PR comments
6. Use `:PROpen` to open the PR in your browser
7. Use `:PRDiff` to see all changes in a single buffer
8. Use `:PRComments` to view all comments on the PR
9. Use `:PRSubmitReview` to submit your review (approve, request changes, or comment)

## Tips

- When adding a comment or review, press `<leader>s` to submit it
- Use `:PRDiff` to get a full overview of all changes in the PR
- After reviewing files using the quickfix list, use `:PRSubmitReview` to finalize your review 