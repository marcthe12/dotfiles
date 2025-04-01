return {
	cmd = { 'vscode-json-language-server', '--stdio' },
	filetypes = { 'json', 'jsonc' },
	init_options = {
		provideFormatter = true,
	},
	root_marker = {},
	single_file_support = true,
}

