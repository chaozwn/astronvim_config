local methods = vim.lsp.protocol.Methods

local rename_handler = vim.lsp.handlers[methods.textDocument_rename]
local auto_save_after_rename_handler = function(err, result, ctx, config)
  rename_handler(err, result, ctx, config)

  if not result or not result.documentChanges then return end

  for _, documentChange in pairs(result.documentChanges) do
    local textDocument = documentChange.textDocument
    if textDocument and textDocument.uri then
      local bufnr = vim.uri_to_bufnr(textDocument.uri)
      if vim.fn.bufloaded(bufnr) == 1 then
        vim.schedule(function()
          vim.api.nvim_buf_call(bufnr, function() vim.cmd "write" end)
        end)
      end
    end
  end
end

-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  version = false,
  branch = "v3",
  ---@type AstroLSPOpts
  ---@diagnostic disable-next-line: assign-type-mismatch
  opts = function(_, opts)
    local mappings = require("mapping").lsp_mappings(opts.mappings)

    return require("astrocore").extend_tbl(opts, {
      -- Configuration table of features provided by AstroLSP
      features = {
        codelens = true, -- enable/disable codelens refresh on start
        inlay_hints = false, -- enable/disable inlay hints on start
        semantic_tokens = true, -- enable/disable semantic token highlighting
        signature_help = false,
      },
      -- enable servers that you already have installed without mason
      servers = {
        -- "pyright"
      },
      -- customize language server configuration options passed to `lspconfig`
      ---@diagnostic disable: missing-fields
      config = {
        -- clangd = { capabilities = { offsetEncoding = "utf-8" } },
      },
      -- customize how language servers are attached
      handlers = {
        -- a function without a key is simply the default handler, functions take two parameters, the server name and the configured options table for that server
        -- function(server, opts) require("lspconfig")[server].setup(opts) end

        -- the key is the server that is being setup with `lspconfig`
        -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
        -- pyright = function(_, opts) require("lspconfig").pyright.setup(opts) end -- or a custom handler function can be passed
      },
      -- Configure buffer local auto commands to add when attaching a language server
      autocmds = {},
      -- mappings to be set up on attaching of a language server
      mappings = mappings,
      -- A custom `on_attach` function to be run after the default `on_attach` function
      -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
      on_attach = function(client, bufnr)
        -- this would disable semanticTokensProvider for all clients
      end,
      lsp_handlers = {
        [methods.textDocument_rename] = auto_save_after_rename_handler,
      },
    })
  end,
}
