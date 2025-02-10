return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "macchiato", -- Options: latte, frappe, macchiato, mocha
				integrations = {
					treesitter = true,
					telescope = true,
					cmp = true,
					gitsigns = true,
					nvimtree = true,
					markdown = true,
					indent_blankline = { enabled = true },
				},
			})
			vim.cmd("colorscheme catppuccin")
		end,
	},
}
