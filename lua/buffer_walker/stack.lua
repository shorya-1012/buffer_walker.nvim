Stack = {
  values = {},
  size = 0
}
Stack.__index = Stack

function Stack.new()
  local obj = {
    values = {},
    size = 0
  }
  setmetatable(obj, Stack)
  return obj
end

function Stack:push(val)
  table.insert(self.values, val)
  self.size = self.size + 1
end

function Stack:pop()
  if self.size == 0 then
    return -1
  end
  local val = table.remove(self.values, self.size);
  self.size = self.size - 1
  return val
end

function Stack:top()
  if self.size == 0 then
    return -1
  end
  return self.values[self.size]
end

function Stack:is_empty()
  if self.size == 0 then
    return true
  end
  return false
end

return Stack
