-- GitLens-style blame at the end of the current line, in a faded color: who changed it, when, the
-- commit title and the pull request that brought it in. The PR number comes from GitHub through
-- the gh CLI, looked up once per commit in the background, so it shows up a moment after the rest.

local prs = {} -- sha -> PR number, false when there is none, true while the lookup is running

-- Earliest merged PR containing the commit (the one that introduced it, not the later
-- develop -> staging -> main merges), otherwise the earliest open one
local jq = "(map(select(.merged_at)) | sort_by(.merged_at) | .[0].number) // (sort_by(.number) | .[0].number) // empty"

local function lookup_pr(sha, cwd)
  prs[sha] = true
  vim.system({ "gh", "api", "repos/{owner}/{repo}/commits/" .. sha .. "/pulls", "--jq", jq }, {
    cwd = cwd,
    text = true,
  }, function(out)
    prs[sha] = out.code == 0 and tonumber(vim.trim(out.stdout)) or false
    if prs[sha] then
      vim.schedule(function()
        require("gitsigns.current_line_blame").refresh()
      end)
    end
  end)
end

local function relative_time(time)
  local seconds = os.time() - time
  for _, unit in ipairs({
    { 365 * 24 * 3600, "year" },
    { 30 * 24 * 3600, "month" },
    { 7 * 24 * 3600, "week" },
    { 24 * 3600, "day" },
    { 3600, "hour" },
    { 60, "minute" },
  }) do
    local n = math.floor(seconds / unit[1])
    if n >= 1 then
      return ("%d %s%s ago"):format(n, unit[2], n == 1 and "" or "s")
    end
  end
  return "just now"
end

return {
  "lewis6991/gitsigns.nvim",
  opts = {
    current_line_blame = true,
    current_line_blame_opts = { delay = 300 },
    current_line_blame_formatter = function(username, info)
      local text = ("%s, %s • %s"):format(
        info.author == username and "You" or info.author,
        relative_time(info.author_time),
        info.summary
      )
      -- Squash merges already carry "(#123)" in the title
      if not text:find("#%d+") then
        local pr = prs[info.sha]
        if pr == nil then
          lookup_pr(info.sha, vim.fn.expand("%:p:h"))
        elseif type(pr) == "number" then
          text = text .. (" (#%d)"):format(pr)
        end
      end
      return { { "    " .. text, "GitSignsCurrentLineBlame" } }
    end,
  },
}
