-- Run by sync.sh inside a headless Neovim. Installs every Mason package (language servers,
-- formatters, linters) and every treesitter parser this setup uses, and waits for them, so a Mac
-- is fully ready before you open Neovim. "Uses" means what the config asks for plus what's listed
-- in mason.txt and treesitter.txt. Afterwards both lists are rewritten with everything installed,
-- so a tool added by hand through :Mason shows up in `git diff`, ready to commit.

local dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")

local function say(msg)
  io.stdout:write(msg .. "\n")
end

local function read(name)
  local list = {}
  if vim.fn.filereadable(dir .. "/" .. name) == 1 then
    for _, line in ipairs(vim.fn.readfile(dir .. "/" .. name)) do
      line = vim.trim(line)
      if line ~= "" and not line:match("^#") then
        table.insert(list, line)
      end
    end
  end
  return list
end

local function write(name, header, list)
  table.sort(list)
  vim.fn.writefile(vim.list_extend({ header }, list), dir .. "/" .. name)
end

local function unique(list)
  local seen, out = {}, {}
  for _, item in ipairs(list) do
    if not seen[item] then
      seen[item] = true
      table.insert(out, item)
    end
  end
  table.sort(out)
  return out
end

local failed = {}

-- Loading these starts LazyVim's own installs too; the loop below skips anything already
-- installing and waits for it along with the rest
require("lazy").load({ plugins = { "mason.nvim", "mason-lspconfig.nvim", "nvim-lspconfig", "nvim-treesitter" } })

-- Mason: the config's tools, a package for every language server it sets up, and mason.txt
local registry = require("mason-registry")
local packages = read("mason.txt")
vim.list_extend(packages, LazyVim.opts("mason.nvim").ensure_installed or {})
local server_packages = require("mason-lspconfig").get_mappings().lspconfig_to_package
for server, opts in pairs(LazyVim.opts("nvim-lspconfig").servers or {}) do
  local enabled = opts == true or (type(opts) == "table" and opts.enabled ~= false and opts.mason ~= false)
  if server ~= "*" and enabled and server_packages[server] then
    table.insert(packages, server_packages[server])
  end
end
packages = unique(packages)

local refreshed = false
registry.refresh(function()
  refreshed = true
end)
vim.wait(120000, function()
  return refreshed
end, 200)

for _, name in ipairs(packages) do
  if not registry.has_package(name) then
    table.insert(failed, name .. " (not in Mason's registry)")
  else
    local pkg = registry.get_package(name)
    if not pkg:is_installed() and not pkg:is_installing() then
      say("Installing " .. name)
      pkg:install()
    end
  end
end
vim.wait(1200000, function()
  for _, name in ipairs(packages) do
    if registry.has_package(name) and registry.get_package(name):is_installing() then
      return false
    end
  end
  return true
end, 1000)
for _, name in ipairs(packages) do
  if registry.has_package(name) and not registry.get_package(name):is_installed() then
    table.insert(failed, name)
  end
end

-- Treesitter: the config's parsers plus treesitter.txt. Building them needs tree-sitter-cli
-- (in the Brewfile) and a C compiler (from `xcode-select --install`).
local ts = require("nvim-treesitter")
local parsers = read("treesitter.txt")
vim.list_extend(parsers, LazyVim.opts("nvim-treesitter").ensure_installed or {})
parsers = unique(parsers)
local function missing_parsers()
  local have = {}
  for _, lang in ipairs(ts.get_installed("parsers")) do
    have[lang] = true
  end
  return vim.tbl_filter(function(lang)
    return not have[lang]
  end, parsers)
end
local missing = missing_parsers()
if #missing > 0 then
  say("Installing parsers: " .. table.concat(missing, ", "))
  pcall(function()
    ts.install(missing, { summary = true }):wait(1200000)
  end)
end
for _, lang in ipairs(missing_parsers()) do
  table.insert(failed, lang .. " parser")
end

write("mason.txt", "# Mason packages installed on this Mac; sync.sh installs these everywhere", registry.get_installed_package_names())
write("treesitter.txt", "# Treesitter parsers installed on this Mac; sync.sh installs these everywhere", ts.get_installed("parsers"))

if #failed > 0 then
  say("Couldn't install: " .. table.concat(failed, ", "))
  vim.cmd("cquit 1")
end
say("Language servers, formatters, linters and parsers are all installed.")
vim.cmd("qa!")
