local M = {}

-- Toggle checkbox on current line
function M.toggle_checkbox()
  local line = vim.api.nvim_get_current_line()
  local new_line = line

  -- Check if line has unchecked checkbox: - [ ] or * [ ] or + [ ]
  if line:match("^%s*[%*%-+]%s%[%s%]") then
    -- Change to checked: - [x]
    new_line = line:gsub("^(%s*[%*%-+])%s%[%s%]", "%1 [x]")

  -- Check if line has checked checkbox: - [x] or * [x] or + [x]
  elseif line:match("^%s*[%*%-+]%s%[x%]") then
    -- Remove checkbox entirely: - [x] -> -
    new_line = line:gsub("^(%s*[%*%-+])%s%[x%]%s?", "%1 ")

  -- Check if line is a plain list item: - or * or +
  elseif line:match("^%s*[%*%-+]%s[^%[]") or line:match("^%s*[%*%-+]%s*$") then
    -- Add unchecked checkbox: - -> - [ ]
    new_line = line:gsub("^(%s*[%*%-+])%s?", "%1 [ ] ")
  end

  -- Set the modified line
  vim.api.nvim_set_current_line(new_line)
end

-- Continue list item on new line (for 'o' and insert mode <CR>)
-- split_at_cursor: if true, split the line at cursor position (for insert mode <CR>)
function M.continue_list(split_at_cursor)
  local line = vim.api.nvim_get_current_line()
  local indent, bullet, checkbox, content
  local prefix_len -- length of the prefix (indent + bullet + checkbox + spaces)

  -- Match list patterns:
  -- 1. With checkbox: "    - [ ] text" or "    - [x] text"
  -- 2. Without checkbox: "    - text"
  indent, bullet, checkbox, content = line:match("^(%s*)([%*%-+])%s(%[.%])%s(.*)$")

  if indent then
    -- indent + bullet + space + checkbox + space
    prefix_len = #indent + 1 + 1 + 3 + 1
  else
    -- Try without checkbox
    indent, bullet, content = line:match("^(%s*)([%*%-+])%s(.*)$")
    checkbox = nil
    if indent then
      -- indent + bullet + space
      prefix_len = #indent + 1 + 1
    end
  end

  -- If current line is a list item
  if bullet then
    -- Check if the list item is empty (no content after bullet/checkbox)
    if content == "" or content == nil then
      -- Empty list item: remove bullet and unindent
      local new_indent = indent:sub(5) or "" -- Remove 4 spaces (one level)
      if new_indent == "" and indent == "" then
        -- Already at root level, just clear the line
        vim.api.nvim_set_current_line("")
      else
        vim.api.nvim_set_current_line(new_indent)
      end
      return true -- Handled
    else
      -- Non-empty list item: continue with new bullet
      local new_prefix
      if checkbox then
        -- Continue with unchecked checkbox
        new_prefix = indent .. bullet .. " [ ] "
      else
        -- Continue with plain bullet
        new_prefix = indent .. bullet .. " "
      end

      local row = vim.api.nvim_win_get_cursor(0)[1]
      local col = vim.api.nvim_win_get_cursor(0)[2]

      -- If split_at_cursor is true and cursor is in the middle of content,
      -- split the line at cursor position
      if split_at_cursor and col >= prefix_len and col < #line then
        -- Calculate position within content
        local content_pos = col - prefix_len
        local content_before = content:sub(1, content_pos):gsub("%s+$", "") -- right-trim
        local content_after = content:sub(content_pos + 1):gsub("^%s+", "") -- left-trim

        -- Update current line with content before cursor
        local current_line
        if checkbox then
          current_line = indent .. bullet .. " " .. checkbox .. " " .. content_before
        else
          current_line = indent .. bullet .. " " .. content_before
        end
        vim.api.nvim_set_current_line(current_line)

        -- Create new line with content after cursor
        local new_line = new_prefix .. content_after

        -- Insert new line below and set content
        vim.api.nvim_buf_set_lines(0, row, row, false, { new_line })
        vim.api.nvim_win_set_cursor(0, { row + 1, #new_prefix })
      else
        -- Cursor at end of line or split not requested: create empty new list item
        local new_line = new_prefix

        -- Insert new line below and set content
        vim.api.nvim_buf_set_lines(0, row, row, false, { new_line })
        vim.api.nvim_win_set_cursor(0, { row + 1, #new_line })
      end
      return true -- Handled
    end
  end

  return false -- Not a list item, let default behavior happen
end

-- Handle 'o' in normal mode
function M.handle_o()
  if M.continue_list() then
    vim.cmd("startinsert!")
  else
    -- Default 'o' behavior
    vim.cmd("normal! o")
    vim.cmd("startinsert")
  end
end

-- Handle 'O' in normal mode
function M.handle_O()
  -- For 'O' we just use default behavior (insert line above)
  vim.cmd("normal! O")
  vim.cmd("startinsert")
end

-- Handle <CR> in insert mode
function M.handle_cr()
  if not M.continue_list(true) then
    -- Not a list, use default <CR>
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
  end
end

-- Handle Tab in insert mode (indent empty list items)
function M.handle_tab()
  local line = vim.api.nvim_get_current_line()
  local indent, bullet, checkbox, content

  -- Match list patterns to check if it's an empty list item
  indent, bullet, checkbox, content = line:match("^(%s*)([%*%-+])%s(%[.%])%s(.*)$")

  if not indent then
    -- Try without checkbox
    indent, bullet, content = line:match("^(%s*)([%*%-+])%s(.*)$")
    checkbox = nil
  end

  -- If it's a list item and empty (no content)
  if bullet and (content == "" or content == nil) then
    -- Add 4 spaces of indentation
    local new_line
    if checkbox then
      new_line = indent .. "    " .. bullet .. " " .. checkbox .. " "
    else
      new_line = indent .. "    " .. bullet .. " "
    end
    vim.api.nvim_set_current_line(new_line)
    -- Move cursor to end of line
    vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], #new_line })
    return true -- Handled
  end

  -- Not an empty list item, use default tab
  return false
end

-- Handle Shift+Tab in insert mode (unindent empty list items)
function M.handle_shift_tab()
  local line = vim.api.nvim_get_current_line()
  local indent, bullet, checkbox, content

  -- Match list patterns to check if it's an empty list item
  indent, bullet, checkbox, content = line:match("^(%s*)([%*%-+])%s(%[.%])%s(.*)$")

  if not indent then
    -- Try without checkbox
    indent, bullet, content = line:match("^(%s*)([%*%-+])%s(.*)$")
    checkbox = nil
  end

  -- If it's a list item and empty (no content)
  if bullet and (content == "" or content == nil) then
    -- Remove 4 spaces of indentation (if possible)
    if #indent >= 4 then
      local new_indent = indent:sub(5) -- Remove first 4 spaces
      local new_line
      if checkbox then
        new_line = new_indent .. bullet .. " " .. checkbox .. " "
      else
        new_line = new_indent .. bullet .. " "
      end
      vim.api.nvim_set_current_line(new_line)
      -- Move cursor to end of line
      vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], #new_line })
      return true -- Handled
    end
  end

  -- Not an empty list item or can't unindent, use default behavior
  return false
end

-- Setup function to configure keymaps
function M.setup(opts)
  opts = opts or {}
  local keymap = opts.keymap or "<Space>"

  -- Create autocommand for markdown files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      -- Toggle checkbox
      vim.keymap.set("n", keymap, function()
        require("markdown-checkbox").toggle_checkbox()
      end, {
        buffer = true,
        desc = "Toggle markdown checkbox"
      })

      -- Continue list on 'o' in normal mode
      vim.keymap.set("n", "o", function()
        require("markdown-checkbox").handle_o()
      end, {
        buffer = true,
        desc = "Continue list or open line below"
      })

      -- Keep default behavior for 'O'
      vim.keymap.set("n", "O", function()
        require("markdown-checkbox").handle_O()
      end, {
        buffer = true,
        desc = "Open line above"
      })

      -- Continue list on <CR> in insert mode
      vim.keymap.set("i", "<CR>", function()
        require("markdown-checkbox").handle_cr()
      end, {
        buffer = true,
        desc = "Continue list or new line"
      })

      -- Handle Tab for indenting empty list items
      vim.keymap.set("i", "<Tab>", function()
        if not require("markdown-checkbox").handle_tab() then
          -- Use default tab behavior
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
        end
      end, {
        buffer = true,
        desc = "Indent empty list item or default tab"
      })

      -- Handle Shift+Tab for unindenting empty list items
      vim.keymap.set("i", "<S-Tab>", function()
        if not require("markdown-checkbox").handle_shift_tab() then
          -- Use default shift-tab behavior
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, false, true), "n", false)
        end
      end, {
        buffer = true,
        desc = "Unindent empty list item or default shift-tab"
      })
    end
  })
end

return M
