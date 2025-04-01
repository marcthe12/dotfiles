return {
	cmd = { 'ruff', 'server' },
	filetypes = { 'python' },
	root_marker = {
		'pyproject.toml',
		'ruff.toml',
		'.ruff.toml'
	},
	single_file_support = true,
}
