## BUFFER WALKER
A simple Neovim plugin that lets you walk back and forward through previously visited buffers — like browser-style back/forward navigation.

## ✨ Features
- Maintains two stacks to enable both forward and backward navigation
- Navigate **backward** to the previously visited buffer.
- Navigate **forward** after going back.
- Skips invalid or closed buffers automatically.
- Prevents infinite loops when switching buffers with the plugin.

## 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
return {
  "shorya-1012/buffer_walker.nvim",
  config = function()
      vim.keymap.set("n", "<leader>,", ":MoveBack<CR>", { silent = true })
      vim.keymap.set("n", "<leader>.", ":MoveForward<CR>", { silent = true })
  end
}
```

## Usage : 
Use the commands *MoveBack* and *MoveForward* or use the key binds.

