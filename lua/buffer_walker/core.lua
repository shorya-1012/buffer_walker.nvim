local Stack = require "buffer_walker.stack"

local prev_buffers = Stack.new()
local next_buffers = Stack.new()

--[[
  I push buffers to the stack after leaving them.
  So I need to check whether the buffer switch was triggered by this plugin or by an external
  command (e.g. `:e buffer`).

  If the switch was caused by this plugin, adding the buffer
  to the stack will cause a loop.
]] --
local navigating = false
local coming_from = nil

-- add buffer to prev_buffers stack when leaving buffer
vim.api.nvim_create_autocmd({ "BufLeave" }, {
  callback = function(args)
    if navigating then
      return -- do not add to stack if buffer was left using the plugin
    end
    local buf = args.buf
    if vim.api.nvim_buf_is_valid(buf) and (prev_buffers:is_empty() or prev_buffers:top() ~= buf) then
      prev_buffers:push(buf)
      --[[
          This is soley to avoid the case as follows
          open buffer A
          go to buffer B
          move back from B to A
          from A open C

          Without this the above chain of events would cause B to be the next buffer of C
          which would be semantically incorrect
      ]] --
      if coming_from == next_buffers:top() then
        next_buffers:clear()
      end
    end
  end
})


local get_previous_buff = function()
  -- add current buffer to forward stack
  local curr_buffer = vim.api.nvim_get_current_buf()

  -- remove invalid buffers from stack
  while not prev_buffers:is_empty()
    and (not vim.api.nvim_buf_is_valid(prev_buffers:top()) or curr_buffer == prev_buffers:top()) do
    prev_buffers:pop()
  end

  return prev_buffers:pop()
end

local get_next_buffer = function()
  -- remove invaild buffers
  while not next_buffers:is_empty() and not vim.api.nvim_buf_is_valid(next_buffers:top()) do
    next_buffers:pop()
  end

  return next_buffers:pop()
end

local move_backward = function()
  local prev_buff = get_previous_buff()
  if prev_buff == -1 then
    print("No buffers to move back to!")
  else
    local curr_buffer = vim.api.nvim_get_current_buf()
    next_buffers:push(curr_buffer) --
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
