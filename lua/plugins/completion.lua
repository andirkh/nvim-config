-- Completion closer to VS Code's: quieter, but more forgiving about what you type.

-- Treesitter kind of the text just before the cursor: "comment", "string" or nil
local function context_kind()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, row - 1, math.max(col - 1, 0))
  for _, capture in ipairs(ok and captures or {}) do
    local kind = capture.capture:match("^(comment)") or capture.capture:match("^(string)")
    if kind then
      return kind
    end
  end
end

return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      menu = {
        -- Like VS Code, no suggestions while writing a comment, and in strings only real ones from
        -- the language servers (Tailwind classes, import paths, typed string values), not the
        -- words-from-this-file list
        auto_show = function(ctx, items)
          local kind = context_kind()
          if kind == "comment" then
            return ctx.trigger.initial_kind == "trigger_character"
          end
          if kind == "string" then
            for _, item in ipairs(items) do
              if item.source_id ~= "buffer" then
                return true
              end
            end
            return false
          end
          return true
        end,
      },
    },
    sources = {
      providers = {
        -- Snippets wait for a second letter instead of flooding the list after the first one
        snippets = { min_keyword_length = 2 },
      },
    },
    fuzzy = {
      -- One typo allowed from three letters on and two from seven (blink's default waits until
      -- four and eight), with exact matches still first so the extra leeway doesn't bury them
      max_typos = function(keyword)
        return math.floor((#keyword + 1) / 4)
      end,
      sorts = { "exact", "score", "sort_text" },
    },
    -- Typing a : command no longer pops up a menu; Tab still completes it, as in plain Vim
    cmdline = {
      completion = { menu = { auto_show = false } },
    },
  },
}
