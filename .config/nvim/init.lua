vim.loader.enable()

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.number = true
vim.o.relativenumber = true
vim.o.title = true
vim.o.termguicolors = true

vim.opt.shortmess:append("sI")

vim.o.splitright = true
vim.o.splitbelow = true

vim.g.netrw_keepdir = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 30

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python_provider = 0

vim.o.list = true
vim.o.mouse = 'a'

vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.foldmethod = "expr"
vim.o.foldcolumn = "auto"

vim.o.cursorline = true
vim.o.laststatus = 2
vim.o.statusline = "%!v:lua.require'lines'.status()"
vim.o.tabline = "%!v:lua.require'lines'.tab()"
vim.o.signcolumn = 'yes'
vim.opt.fillchars = {
	foldopen = "⌵",
	foldclose = "›",
	eob = " "
}

vim.o.showtabline = 2

vim.cmd.colorscheme('retrobox')

vim.keymap.set({ 'n', 'x' }, '<leader>y', '"+y')
vim.keymap.set('n', '<leader>p', '"+p')
vim.keymap.set('x', '<leader>p', '"+P')

vim.o.colorcolumn = '+1'

vim.o.hlsearch = true
vim.keymap.set('n', '<Esc>', function()
	vim.cmd.nohlsearch()
end)

vim.keymap.set('n', '<leader>t', function()
	vim.cmd.split()
	vim.cmd.terminal()
end)

vim.keymap.set('n', '<leader>o', function()
	vim.cmd.Lexplore()
end)

vim.keymap.set('n', '<leader>O', function()
	vim.cmd.Lexplore(vim.fn.expand "%:p:h")
end)

for _, value in ipairs({
	'<Up>', '<Up>', '<Down>', '<Left>', '<Right>',
	'<Home>', '<End>', '<PageUp>', '<PageDown>'
}) do
	vim.keymap.set({ 'n', 'i' }, value, '<Nop>', { noremap = true, silent = false })
end

require 'nvim-treesitter.configs'.setup {
	highlight = {
		enable = true,
	},
	indent = { enable = true },
	auto_install = true,
}

vim.keymap.set('n', '<leader>q', function()
	vim.diagnostic.setloclist()
end)

require 'conform'.setup {}

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
vim.keymap.set('n', '<leader>f', function()
	require('conform').format { async = true, lsp_format = "fallback", }
end)

vim.api.nvim_create_user_command("Format", function(args)
	local range = nil
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, end_line:len() },
		}
	end
	require("conform").format { async = true, lsp_format = "fallback", range = range }
end, { range = true })

vim.keymap.set({ 'n', 'v' }, 'grl', function()
	vim.lsp.codelens.run()
end)

vim.keymap.set('n', '<leader>wa', function()
	vim.lsp.buf.add_workspace_folder()
end)

vim.keymap.set('n', '<leader>wr', function()
	vim.lsp.buf.remove_workspace_folder()
end)

vim.keymap.set('n', '<leader>wl', function()
	local dir = vim.lsp.buf.list_workspace_folders()
	vim.ui.select(dir, {
		prompt = 'Workspace Dir: ',
	}, function(result)
		if result then
			vim.api.nvim_set_current_dir(result)
		end
	end)
end)

vim.api.nvim_create_user_command("Symbols", function(args)
	if args.args == ""
	then
		vim.lsp.buf.workspace_symbol()
	else
		vim.lsp.buf.workspace_symbol(args.args)
	end
end, { nargs = "?" })

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local opts = { buffer = ev.buf }
		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
			vim.lsp.inlay_hint.enable()
		end

		if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
			local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight',
				{ clear = false })
			vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
				buffer = ev.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
				buffer = ev.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.clear_references,
			})

			vim.api.nvim_create_autocmd('LspDetach', {
				callback = function(event)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds {
						group = highlight_augroup,
						buffer = event.buf
					}
				end,
			})
		end

		if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_codelens) then
			vim.lsp.codelens.refresh(opts)
			vim.api.nvim_create_autocmd({ 'CursorHold', 'InsertLeave' }, {
				buffer = ev.buf,
				callback = function()
					vim.lsp.codelens.refresh(opts)
				end,
			})
		end
	end,
})

--- Setup LSP Server with lspconfig and nvim-cmp
---@param server_name string
---@param settings ?lspconfig.Config
local function setupLSP(server_name, settings)
	settings = settings or {}
	settings.capabilities = vim.tbl_deep_extend(
		"force",
		{},
		vim.lsp.protocol.make_client_capabilities(),
		require 'cmp_nvim_lsp'.default_capabilities()
	)
	require "lspconfig"[server_name].setup(settings)
end


require 'mason'.setup {}
require 'mason-lspconfig'.setup {
	ensure_installed = { 'lua_ls' },
	handlers = {
		function(server_name)
			setupLSP(server_name)
		end,
		lua_ls = function()
			setupLSP("lua_ls", {
				settings = {
					Lua = {
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
			})
		end,
		gopls = function()
			setupLSP("gopls", {
				settings = {
					gopls = {
						hints = {
							rangeVariableTypes = true,
							parameterNames = true,
							constantValues = true,
							assignVariableTypes = true,
							compositeLiteralFields = true,
							compositeLiteralTypes = true,
							functionTypeParameters = true,
						},
						codelenses = {
							gc_details = true,
						}
					},
				}
			})
		end,
		clangd = function()
			setupLSP("clangd", {
				settings = {
					clangd = {
						InlayHints = {
							Designators = true,
							Enabled = true,
							ParameterNames = true,
							DeducedTypes = true,
						},
						fallbackFlags = { "-std=c++20" },
					},
				}
			})
		end,
		ts_ls = function()
			setupLSP("ts_ls", {
				settings = {
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayVariableTypeHintsWhenTypeMatchesName = false,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
					javascript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayVariableTypeHintsWhenTypeMatchesName = false,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
				}
			})
		end,
		rust_analyzer = function() end,
	}
}

local cmp = require 'cmp'
local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup {
	snippet = {
		expand = function(args)
			vim.snippet.expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		['<Up>'] = cmp.mapping.select_prev_item(cmp_select),
		['<Down>'] = cmp.mapping.select_next_item(cmp_select),
	}),
	sources = cmp.config.sources({
		{
			name = 'lazydev',
			group_index = 0,
		},
		{ name = 'nvim_lsp' },
	}, {
		{ name = 'buffer' },
	})
}
