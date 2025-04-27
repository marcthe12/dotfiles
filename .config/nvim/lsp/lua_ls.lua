return {
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT'
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true)
			},
			completion = {
				callSnippet = 'Replace',
			},
			diagnostics = {
				disable = { 'missing-fields' }
			},
			hint = {
				enable = true
			}
		},
	}
}
