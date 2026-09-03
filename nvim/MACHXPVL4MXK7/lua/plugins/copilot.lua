return {
    "github/copilot.vim",
    config = function()
        vim.api.nvim_set_keymap("i", "<C-\\>", "<Plug>(copilot-dismiss)", { noremap = true, silent = true })
        vim.api.nvim_set_keymap("i", "<C-j>", "<Plug>(copilot-next)", { noremap = true, silent = true })
        vim.api.nvim_set_keymap("i", "<C-k>", "<Plug>(copilot-previous)", { noremap = true, silent = true })
    end,
}
