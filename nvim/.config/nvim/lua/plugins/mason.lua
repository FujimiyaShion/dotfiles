return {
    "mason-org/mason.nvim",
    event = "VeryLazy",
    dependencies = {
        "neovim/nvim-lspconfig",
        "mason-org/mason-lspconfig.nvim",
    },
    opts = {},
    config = function (_, opts)
        require("mason").setup(opts)
        require("mason-lspconfig").setup({
            ensure_installed = { "lua_ls", "pyright", "html", "cssls", "ts_ls" },
            automatic_enable = true,
        })
        vim.diagnostic.config({
            virtual_text = true,
            update_in_insert = true,
        })
    end,
}

