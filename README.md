# markdown-checkbox.nvim

A minimal Neovim plugin for toggling markdown checkboxes.

It's a logic port of the unmaintained markdown plugin [gabrielelana/vim-markdown](https://github.com/gabrielelana/vim-markdown).

## Features

### Toggle checkboxes

Press `<Space>` in normal mode to toggle checkboxes:

- `- foo` → `- [ ] foo` (add unchecked checkbox)
- `- [ ] foo` → `- [x] foo` (check the checkbox)
- `- [x] foo` → `- foo` (remove checkbox)

### Auto-continue lists

- Press `o` in normal mode or `<Enter>` in insert mode to automatically create a new list item
- On an empty list item, pressing `<Enter>` removes the bullet and unindents

Works with `*`, `-`, and `+` list markers.

## Installation

### Lazy.nvim

```lua
{
  "mmvsk/markdown-checkbox.nvim",
  ft = "markdown",
  config = function()
    require("markdown-checkbox").setup()
  end
}
```

Or if you want to customize the keymap:

```lua
{
  "mmvsk/markdown-checkbox.nvim",
  ft = "markdown",
  config = function()
    require("markdown-checkbox").setup({
      keymap = "<Space>" -- default
    })
  end
}
```

### vim-plug

```vim
Plug 'mmvsk/markdown-checkbox.nvim'
```

Then in your config:

```lua
require("markdown-checkbox").setup()
```

### packer.nvim

```lua
use {
  "mmvsk/markdown-checkbox.nvim",
  ft = "markdown",
  config = function()
    require("markdown-checkbox").setup()
  end
}
```

## Usage

In a markdown file, position your cursor on a list item line and press `<Space>` in normal mode to toggle the checkbox state.
