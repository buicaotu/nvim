# My Neovim Configuration

This is my personal Neovim configuration.

## Prerequisites

- Neovim
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder
- [fd](https://github.com/sharkdp/fd) - A simple, fast and user-friendly alternative to find
- [ripgrep](https://github.com/BurntSushi/ripgrep) - A line-oriented search tool
- [Node.js](https://nodejs.org/) and npm - For JavaScript/TypeScript development
- Git - For version control and git integration

## Installation

1. Clone this repository to your Neovim config directory:

```bash
git clone git@github.com:buicaotu/nvim.git ~/.config/nvim
```

2. Install dependencies:

```bash
# macOS
brew install fzf fd ripgrep node git
```

3. Start Neovim and plugins will be automatically installed via lazy.nvim
