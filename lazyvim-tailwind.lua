return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"roobert/tailwindcss-colorizer-cmp.nvim",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
		},
		opts = function(_, opts)
			local cmp = require("cmp")
			local tailwindcss_colorizer = require("tailwindcss-colorizer-cmp").formatter
			opts.formatting = {
				format = function(entry, item)
					item = tailwindcss_colorizer(entry, item)
					return item
				end,
			}
		end,
	},
	{
		"NvChad/nvim-colorizer.lua",
		event = "BufReadPre",
		opts = {
			filetypes = { "css", "scss", "sass", "html", "javascript", "typescript", "jsx", "tsx", "astro" },
			user_default_options = {
				RGB = true,
				RRGGBB = true,
				names = true,
				RRGGBBAA = true,
				rgb_fn = true,
				hsl_fn = true,
				css = true,
				css_fn = true,
				tailwind = true,
				mode = "background",
			},
		},
	},
}
