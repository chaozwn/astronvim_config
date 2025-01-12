---@type LazySpec
return {
  "AstroNvim/astrolsp",
  version = false,
  branch = "v3",
  ---@type AstroLSPOpts
  ---@diagnostic disable-next-line: assign-type-mismatch
  opts = function(_, opts)
    local mappings = require("mapping").lsp_mappings(opts.mappings)
    return vim.tbl_deep_extend("force", opts, {
      -- Configuration table of features provided by AstroLSP
      features = {
        codelens = true, -- enable/disable codelens refresh on start
        inlay_hints = false, -- enable/disable inlay hints on start
        semantic_tokens = true, -- enable/disable semantic token highlighting
      },
      -- enable servers that you already have installed without mason
      servers = {},
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
    })
  end,
}
