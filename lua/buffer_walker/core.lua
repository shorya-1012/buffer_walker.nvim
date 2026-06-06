local Stack = require "buffer_walker.stack"

local buffer_versions = {}
local prev_buffers = Stack.new()
local next_buffers = Stack.new()

-- Check whether the swich was caused by the plugin or external command to prevent loops.
local navigating = false
local coming_from = nil

local function push_with_version(stack, buff)
  local v = (buffer_versions[buff] or 0) + 1;
  buffer_versions[buff] = v
  stack:push({ buff = buff, version = v })
end

local function pop_valid(stack)
  while not stack:is_empty() do
    local entry = stack:top()
    if vim.api.nvim_buf_is_valid(entry.buff) and buffer_versions[entry.buff] == entry.version then
      stack:pop()
      return entry.buff
    end
    stack:pop()
  end
  return -1
end

local function top_buff(stack)
  while not stack:is_empty() do
    local entry = stack:top()
    if vim.api.nvim_buf_is_valid(entry.buff) and buffer_versions[entry.buff] == entry.version then
      return entry.buff
    end
    stack:pop()
  end
  return -1
end

-- add buffer to prev_buffers stack when leaving buffer
vim.api.nvim_create_autocmd({ "BufLeave" }, {
  callback = function(args)
    if navigating then
      return -- do not add to stack if buffer was left using the plugin
    end
    local buf = args.buf
    local prev_top = top_buff(prev_buffers)
    if vim.api.nvim_buf_is_valid(buf) and (buf ~= prev_top) then
      push_with_version(prev_buffers, buf)
      -- If we opened a new buffer after going back to previous buffer,
      -- the forward stack becomes meaningless, so clear it
      if coming_from == top_buff(next_buffers) then
        next_buffers:clear()
      end
    end
  end
})


local get_previous_buff = function()
  -- add current buffer to forward stack
  local curr_buffer = vim.api.nvim_get_current_buf()

  -- remove invalid buffers from stack
  while curr_buffer == top_buff(prev_buffers) do
    prev_buffers:pop()
  end

  return pop_valid(prev_buffers)
end

local get_next_buffer = function()
  return pop_valid(next_buffers)
end

local move_backward = function()
  local prev_buff = get_previous_buff()
  if prev_buff == -1 then
    print("No buffers to move back to!")
  else
    local curr_buffer = vim.api.nvim_get_current_buf()
    push_with_version(next_buffers, curr_buffer)
    navigating = true;
    coming_from = curr_buffer
    vim.cmd("buffer " .. prev_buff)
    navigating = false;
  end
end

local move_forward = function()
  local next_buff = get_next_buffer()
  if next_buff == -1 then
    print("No buffers to move forward to!")
  else
    vim.cmd("buffer " .. next_buff)
  end
end

vim.api.nvim_create_user_command("MoveBack", move_backward, {})
vim.api.nvim_create_user_command("MoveForward", move_forward, {})
