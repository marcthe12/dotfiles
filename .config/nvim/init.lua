vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.title = true
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'

vim.g.netrw_keepdir = 0
vim.g.netrw_banner = 0

vim.cmd.colorscheme 'melange'
vim.opt.colorcolumn = '+1'
vim.opt.foldlevel = 2
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false

vim.opt.omnifunc = "syntaxcomplete#Complete"
vim.opt.completeopt = {'menu', 'noinsert'}

require "paq" {
	"savq/paq-nvim", -- Let Paq manage itself
	"savq/melange-nvim",
	"neovim/nvim-lspconfig",
	{ 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
}:sync()

require'nvim-treesitter.configs'.setup {
	highlight = {
		enable = true,
	},
	indent = { enable = true },
	auto_install = true,
	ensure_installed = { "vimdoc", "lua" }
}

require'lspconfig'.clangd.setup{}
require'lspconfig'.tsserver.setup{}
require'lspconfig'.eslint.setup{}
require'lspconfig'.html.setup{}
require'lspconfig'.cssls.setup{}
require'lspconfig'.jsonls.setup{}
require'lspconfig'.pyright.setup{}

vim.keymap.set('i', '<C-Space>', '<C-x><C-o>')
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		local opts = { buffer = ev.buf }
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
		vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set('n', '<space>wl', function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
		vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		vim.keymap.set('n', '<space>f', function()
			vim.lsp.buf.format { async = true }
		end, opts)
	end,
})
