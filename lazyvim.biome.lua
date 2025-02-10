return {
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
		config = function()
			local lspconfig = require("lspconfig")

			-- Function to check if Biome is installed in the project
			local function has_biome()
				return vim.fn.executable(vim.fn.getcwd() .. "/node_modules/.bin/biome") == 1
			end

			-- Setup Biome if available
			if has_biome() then
				lspconfig.biome.setup({
					cmd = { vim.fn.getcwd() .. "/node_modules/.bin/biome", "lsp-proxy" },
					filetypes = { "javascript", "typescript", "json" },
					root_dir = lspconfig.util.root_pattern("biome.json", "package.json", ".git"),
					settings = {
						biome = {
							lspProxy = {
								enable = true,
							},
						},
					},
				})
			end
		end,
	},
}
