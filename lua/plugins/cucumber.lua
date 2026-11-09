-- Gherkin: go to definition (gd) from a scenario step to its step definition, plus step
-- completion and undefined-step warnings, using the same Cucumber language server as VS Code's
-- Cucumber extension. Like that extension it reads "cucumber.features" and "cucumber.glue" from
-- the project's .vscode/settings.json, so projects already set up for VS Code just work.

local function vscode_settings(root)
  local file = io.open(root .. "/.vscode/settings.json")
  if not file then
    return {}
  end
  local text = file:read("*a")
  file:close()
  -- VS Code allows // comments and trailing commas in its settings
  text = text:gsub("^%s*//[^\n]*", ""):gsub("\n%s*//[^\n]*", "\n"):gsub(",(%s*[}%]])", "%1")
  local ok, json = pcall(vim.json.decode, text)
  return ok and type(json) == "table" and json or {}
end

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      cucumber_language_server = {
        settings = { cucumber = {} },
        before_init = function(_, config)
          local json = vscode_settings(config.root_dir or vim.fn.getcwd())
          -- Filled in place: the client already holds this table and answers the server from it
          for _, key in ipairs({ "features", "glue", "parameterTypes", "snippetTemplates" }) do
            config.settings.cucumber[key] = json["cucumber." .. key]
          end
        end,
      },
    },
  },
}
