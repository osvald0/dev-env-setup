return {
	-- Linting (Error Checking) with Biome, ESLint, and JSONLint
	{
		"mfussenegger/nvim-lint",
		event = "BufReadPre",
		config = function()
			local lint = require("lint")

			-- Function to check if a local binary exists
			local function is_executable(bin)
				return vim.fn.executable(vim.fn.getcwd() .. "/node_modules/.bin/" .. bin) == 1
			end

			-- Function to check if a config file exists
			local function config_exists(config_file)
				return vim.fn.filereadable(vim.fn.getcwd() .. "/" .. config_file) == 1
			end

			-- Decide which linter to use
			local function get_linter()
				if is_executable("biome") and config_exists("biome.json") then
					return "biome"
				elseif is_executable("eslint") then
					return "eslint"
				else
					return nil -- No valid linter found
				end
			end

			lint.linters_by_ft = {
				javascript = { get_linter() or "eslint" }, -- Fallback to global ESLint
				typescript = { get_linter() or "eslint" },
				json = { is_executable("biome") and "biome" or "jsonlint" },
				markdown = { "markdownlint" },
			}

			-- Ensure Biome or ESLint uses the correct command
			lint.linters.biome = {
				cmd = vim.fn.getcwd() .. "/node_modules/.bin/biome",
				args = { "check", "--output-format", "json" },
			}
			lint.linters.eslint.cmd = function()
				local eslint_bin = vim.fn.getcwd() .. "/node_modules/.bin/eslint"
				return is_executable("eslint") and eslint_bin or "eslint"
			end

			-- Automatically run linting on save
			vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},

	-- Formatting (Auto-Format on Save) with Biome, Prettier, and Black
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		config = function()
			local conform = require("conform")

			-- Function to check if a local binary exists
			local function is_executable(bin)
				return vim.fn.executable(vim.fn.getcwd() .. "/node_modules/.bin/" .. bin) == 1
			end

			-- Function to check if a config file exists
			local function config_exists(config_file)
				return vim.fn.filereadable(vim.fn.getcwd() .. "/" .. config_file) == 1
			end

			-- Decide which formatter to use
			local function get_formatter()
				if is_executable("biome") and config_exists("biome.json") then
					return "biome"
				elseif is_executable("prettier") then
					return "prettier"
				else
					return nil -- No valid formatter found
				end
			end

			conform.setup({
				formatters_by_ft = {
					javascript = { get_formatter() or "prettier" }, -- Fallback to Prettier
					typescript = { get_formatter() or "prettier" },
					json = { get_formatter() or "prettier" },
					markdown = { "prettier" },
					python = { "black" },
					lua = { "stylua" },
				},

				formatters = {
					biome = {
						command = vim.fn.getcwd() .. "/node_modules/.bin/biome",
						args = { "format", "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
					},
					prettier = {
						command = function()
							local prettier_bin = vim.fn.getcwd() .. "/node_modules/.bin/prettier"
							return is_executable("prettier") and prettier_bin or "prettier"
						end,
						args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
					},
				},

				format_on_save = true,
			})
		end,
	},
}
