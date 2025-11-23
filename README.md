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
- Pressing `<Enter>` in the middle of a list item splits the line at cursor position
- On an empty list item, pressing `<Enter>` removes the bullet and unindents

Works with `*`, `-`, and `+` list markers.

### Indent/unindent list items

- Press `<Tab>` in insert mode to indent a list item (nest it)
- Press `<Shift+Tab>` in insert mode to unindent a list item

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

With custom configuration:

```lua
{
  "mmvsk/markdown-checkbox.nvim",
  ft = "markdown",
  config = function()
    require("markdown-checkbox").setup({
      keymap = "<Space>", -- key to toggle checkboxes (default: "<Space>")
      tab_indent = "anywhere", -- when Tab indents list items (default: "anywhere")
    })
  end
}
```

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `keymap` | `"<Space>"` | Key to toggle checkboxes in normal mode |
| `tab_indent` | `"anywhere"` | When `<Tab>`/`<Shift+Tab>` indents/unindents list items |

### `tab_indent` options

- `"anywhere"` - Tab indents from anywhere in the line (default)
- `"content_start"` - Tab only indents when cursor is at start of content (before any text)
- `"empty_only"` - Tab only indents on empty list items (legacy behavior)

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
