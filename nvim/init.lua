local LOG_FILE = "/home/ubuntu/log.txt"
local SUS_FILE = "/home/ubuntu/sus.txt"

vim.opt.number = true

-- ------------------ utils ------------------

local function timestamp()
  return os.date("%Y-%m-%d %H:%M:%S")
end

local function write_file(lines, path, mode)
  mode = mode or "a"
  local f = assert(io.open(path, mode))
  for _, line in ipairs(lines) do
    f:write(line .. "\n")
  end
  f:close()
end

-- ------------------ logging ------------------

local function WriteNewBuffer()
  if vim.fn.bufname(1) == "" then
    write_file({
      timestamp() .. " : new buffer opened"
    }, LOG_FILE)
  end
end

local function WriteFileOpening()
  local filename = vim.fn.expand("<afile>")
  write_file({
    timestamp() .. " : " .. filename .. " : opened"
  }, LOG_FILE)
end

local function WriteFileSaving()
  local filename = vim.fn.expand("<afile>")
  write_file({
    timestamp() .. " : " .. filename .. " : saved"
  }, LOG_FILE)
end

-- ------------------ buffer monitoring ------------------

local prev_buffer_copy = nil
local prev_char_count = nil

local function WriteBufferCharCount()
  local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local buffer_copy = table.concat(buf_lines, "\n")
  local char_count = #buffer_copy

  local filename = vim.fn.bufname(1)
  if filename == "" then
    filename = "std_buffer"
  end

  -- initialize snapshot
  if not prev_buffer_copy then
    prev_buffer_copy = buffer_copy
    prev_char_count = char_count
    return
  end

  -- suspicious growth
  if (char_count - prev_char_count) > 15 then
    write_file({
      "",
      timestamp() .. " : " .. filename .. " : " ..
        prev_char_count .. " to " .. char_count,
      "=======================START BEFORE=======================",
      prev_buffer_copy,
      "========================END BEFORE======================== : " ..
        prev_char_count,
      "========================START AFTER=======================",
      buffer_copy,
      "=========================END AFTER======================== : " ..
        char_count,
    }, SUS_FILE)
  end

  -- update snapshot
  prev_buffer_copy = buffer_copy
  prev_char_count = char_count

  -- log char count
  write_file({
    timestamp() .. " : " .. filename .. " : " .. char_count
  }, LOG_FILE)
end

-- ------------------ autocmds ------------------

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = WriteFileOpening,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  callback = WriteFileSaving,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = WriteNewBuffer,
})

-- ------------------ timer ------------------

vim.fn.timer_start(1000, function()
  WriteBufferCharCount()
end, { ["repeat"] = -1 })
