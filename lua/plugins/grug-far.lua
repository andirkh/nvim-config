-- Find and replace (Cmd+Option+F) ignores case by default, like VS Code.
-- Option+C in the panel switches between ignoring case and matching it exactly.

vim.api.nvim_create_autocmd("FileType", {
  pattern = "grug-far",
  callback = function(ev)
    vim.keymap.set({ "n", "i" }, "<M-c>", function()
      local on = require("grug-far").get_instance(0):toggle_flags({ "--ignore-case" })[1]
      vim.notify(on and "Find: ignoring case" or "Find: matching case", vim.log.levels.INFO, { title = "grug-far" })
    end, { buffer = ev.buf, desc = "Toggle Match Case" })
  end,
})

return {
  "MagicDuck/grug-far.nvim",
  opts = {
    prefills = { flags = "--ignore-case" },
  },
}
