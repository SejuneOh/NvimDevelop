return {
  "seblyng/roslyn.nvim",
  ft = { "cs", "razor" },
  dependencies = {
    "saghen/blink.cmp",
  },
  opts = {
    filewatching = "auto",
    broad_search = false,
    lock_target = false,
    silent = false,
  },
  config = function(_, opts)
    -- 플러그인 자체 옵션
    require("roslyn").setup(opts)

    -- roslyn LSP 서버 설정 (capabilities, settings)
    vim.lsp.config("roslyn", {
      capabilities = require("blink.cmp").get_lsp_capabilities(),
      on_attach = function(_, bufnr)
        if vim.lsp.inlay_hint then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      end,
      settings = {
        ["csharp|inlay_hints"] = {
          csharp_enable_inlay_hints_for_implicit_object_creation = true,
          csharp_enable_inlay_hints_for_implicit_variable_types = true,
          csharp_enable_inlay_hints_for_lambda_parameter_types = true,
          csharp_enable_inlay_hints_for_types = true,
          dotnet_enable_inlay_hints_for_indexer_parameters = true,
          dotnet_enable_inlay_hints_for_literal_parameters = true,
          dotnet_enable_inlay_hints_for_object_creation_parameters = true,
          dotnet_enable_inlay_hints_for_other_parameters = true,
          dotnet_enable_inlay_hints_for_parameters = true,
        },
        ["csharp|code_lens"] = {
          dotnet_enable_references_code_lens = true,
          dotnet_enable_tests_code_lens = true,
        },
        ["csharp|completion"] = {
          dotnet_show_completion_items_from_unimported_namespaces = true,
          dotnet_show_name_completion_suggestions = true,
        },
        ["csharp|background_analysis"] = {
          dotnet_analyzer_diagnostics_scope = "fullSolution",
          dotnet_compiler_diagnostics_scope = "fullSolution",
        },
        ["csharp|symbol_search"] = {
          dotnet_search_reference_assemblies = true,
        },
      },
    })
  end,
}
