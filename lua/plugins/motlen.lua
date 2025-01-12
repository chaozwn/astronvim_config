local function ensure_kernel_for_venv()
  local venv_path = os.getenv "VIRTUAL_ENV" or os.getenv "CONDA_PREFIX"
  if not venv_path then
    vim.notify("No virtual environment found.", vim.log.levels.WARN)
    return
  end

  -- Canonicalize the venv_path to ensure consistency
  venv_path = vim.fn.fnamemodify(venv_path, ":p")

  -- Check if the kernel spec already exists
  local handle = io.popen "jupyter kernelspec list --json"
  local existing_kernels = {}
  if handle then
    local result = handle:read "*a"
    handle:close()
    local json = vim.fn.json_decode(result)
    -- Iterate over available kernel specs to find the one for this virtual environment
    for kernel_name, data in pairs(json.kernelspecs) do
      existing_kernels[kernel_name] = true -- Store existing kernel names for validation
      local kernel_path = vim.fn.fnamemodify(data.spec.argv[1], ":p") -- Canonicalize the kernel path
      if kernel_path:find(venv_path, 1, true) then
        vim.notify("Kernel spec for this virtual environment already exists.", vim.log.levels.INFO)
        return kernel_name
      end
    end
  end

  -- Prompt the user for a custom kernel name, ensuring it is unique
  local new_kernel_name
  repeat
    new_kernel_name = vim.fn.input "Enter a unique name for the new kernel spec: "
    if new_kernel_name == "" then
      vim.notify("Please provide a valid kernel name.", vim.log.levels.ERROR)
      return
    elseif existing_kernels[new_kernel_name] then
      vim.notify(
        "Kernel name '" .. new_kernel_name .. "' already exists. Please choose another name.",
        vim.log.levels.WARN
      )
      new_kernel_name = nil
    end
  until new_kernel_name

  -- Create the kernel spec with the unique name
  print "Creating a new kernel spec for this virtual environment..."
  local cmd = string.format(
    '%s -m ipykernel install --user --name="%s"',
    vim.fn.shellescape(venv_path .. "/bin/python"),
    new_kernel_name
  )

  os.execute(cmd)
  vim.notify("Kernel spec '" .. new_kernel_name .. "' created successfully.", vim.log.levels.INFO)
  return new_kernel_name
end

---@type LazySpec
return {
  "benlubas/molten-nvim",
  ft = { "python" },
  cmd = {
    "MoltenEvaluateLine",
    "MoltenEvaluateVisual",
    "MoltenEvaluateOperator",
    "MoltenEvaluateArgument",
    "MoltenImportOutput",
  },
  version = "^1", -- use version <2.0.0 to avoid breaking changes
  build = ":UpdateRemotePlugins",
  specs = {
    { "AstroNvim/astroui", opts = { icons = { Molten = "󱓞" } } },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings or {}
        local prefix = "<leader>j"

        maps.n[prefix] = { desc = require("astroui").get_icon("Molten", 1, true) .. "Molten" }
        maps.n[prefix .. "e"] = { "<Cmd>MoltenEvaluateOperator<CR>", desc = "Run operator selection" }
        maps.n[prefix .. "l"] = { "<Cmd>MoltenEvaluateLine<CR>", desc = "Evaluate line" }
        maps.n[prefix .. "c"] = { "<Cmd>MoltenReevaluateCell<CR>", desc = "Re-evaluate cell" }
        maps.n[prefix .. "k"] = { ":noautocmd MoltenEnterOutput<CR>", desc = "Enter Output" }
        maps.v[prefix .. "k"] = {
          function()
            vim.cmd "noautocmd MoltenEnterOutput"
            if vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == "\22" then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
            end
          end,
          desc = "Enter Output",
        }

        maps.n[prefix .. "m"] = { desc = "Commands" }
        maps.n[prefix .. "mi"] = { "<Cmd>MoltenInit<CR>", desc = "Initialize the plugin" }
        maps.n[prefix .. "mh"] = { "<Cmd>MoltenHideOutput<CR>", desc = "Hide Output" }
        maps.n[prefix .. "mI"] = { "<Cmd>MoltenInterrupt<CR>", desc = "Interrupt Kernel" }
        maps.n[prefix .. "mR"] = { "<Cmd>MoltenRestart<CR>", desc = "Restart Kernel" }
        -- Dynamic Kernel Initialization based on Python Virtual Environment
        maps.n[prefix .. "mp"] = {
          function()
            local kernel_name = ensure_kernel_for_venv()
            if kernel_name then
              vim.cmd(("MoltenInit %s"):format(kernel_name))
            else
              vim.notify("No kernel to initialize.", vim.log.levels.WARN)
            end
          end,
          desc = "Initialize for Python venv",
          silent = true,
        }

        maps.v[prefix] = { desc = require("astroui").get_icon("Molten", 1, true) .. "Molten" }
        maps.v[prefix .. "r"] = { ":<C-u>MoltenEvaluateVisual<CR>", desc = "Evaluate visual selection" }

        maps.n["]c"] = { "<Cmd>MoltenNext<CR>", desc = "Next Molten Cel" }
        maps.n["[c"] = { "<Cmd>MoltenPrev<CR>", desc = "Previous Molten Cell" }

        opts.options.g["molten_auto_image_popup"] = false
        opts.options.g["molten_auto_open_html_in_browser"] = false
        opts.options.g["molten_auto_open_output"] = false
        opts.options.g["molten_cover_empty_lines"] = true

        opts.options.g["molten_enter_output_behavior"] = "open_and_enter"
        -- molten_output

        opts.options.g["molten_image_location"] = "both"
        opts.options.g["molten_image_provider"] = "image.nvim"
        opts.options.g["molten_output_show_more"] = true
        opts.options.g["molten_use_border_highlights"] = true

        opts.options.g["molten_output_virt_lines"] = false
        opts.options.g["molten_virt_lines_off_by_1"] = false
        opts.options.g["molten_virt_text_output"] = false
        opts.options.g["molten_wrap_output"] = true

        return opts
      end,
    },
  },
}
