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

-- Setup function to configure keymaps
function M.setup(opts)
  opts = opts or {}
  local keymap = opts.keymap or "<Space>"

  -- Create autocommand for markdown files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      vim.keymap.set("n", keymap, function()
        require("markdown-checkbox").toggle_checkbox()
      end, {
        buffer = true,
        desc = "Toggle markdown checkbox"
      })
    end
  })
end

return M
