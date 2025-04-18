return {
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' },
	root_markers = {
		'.luarc.json',
		'.luarc.jsonc',
		'.luacheckrc',
		'.stylua.toml',
		'stylua.toml',
		'selene.toml',
		'selene.yml',
	},
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
