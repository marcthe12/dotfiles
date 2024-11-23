vim.loader.enable()

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.title = true
vim.opt.termguicolors = true

vim.opt.shortmess:append("sI")

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.g.netrw_keepdir = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 30

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python_provider = 0

vim.opt.list = true
vim.opt.mouse = 'a'

vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldmethod = "expr"
vim.opt.foldcolumn = "auto"

vim.opt.cursorline = true
vim.opt.laststatus = 2
vim.opt.statusline = "%!v:lua.Line.status()"
vim.opt.tabline = "%!v:lua.Line.tab()"
vim.opt.signcolumn = 'yes'
vim.opt.statuscolumn = "%!v:lua.Line.column()"
vim.opt.showtabline = 2

vim.keymap.set({ 'n', 'x' }, '<leader>y', '"+y')
vim.keymap.set('n', '<leader>p', '"+p')
vim.keymap.set('x', '<leader>p', '"+P')

vim.opt.colorcolumn = '+1'

vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', vim.cmd.nohlsearch)

vim.keymap.set('n', '<S-Right>', vim.cmd.bnext)
vim.keymap.set('n', '<S-Left>', vim.cmd.bprev)


Line = require 'lines'

vim.keymap.set('n', '<leader>o', function()
	vim.cmd.Lexplore(vim.fn.expand "%:p:h")
end)

vim.keymap.set('n', '<leader>O', function()
	vim.cmd.Lexplore(vim.fn.expand "%:p:h")
end)

require 'nvim-treesitter.configs'.setup {
	highlight = {
		enable = true,
	},
	indent = { enable = true },
	auto_install = true,
}

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

require 'conform'.setup {}

vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()"
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

vim.keymap.set('n', '<leader>b', function()
	local bufs = vim.tbl_filter(
		function(buffer)
			return vim.bo[buffer].buflisted
		end,
		vim.api.nvim_list_bufs()
	)
	vim.ui.select(bufs, {
		prompt = 'Buffer: ',
		format_item = Line.get_formated_bufname
	}, function(result)
		if result then
			vim.api.nvim_set_current_buf(result)
		end
	end)
end)

vim.keymap.set('n', '<leader>t', function()
	local tabs = vim.api.nvim_list_tabpages()
	vim.ui.select(tabs, {
		prompt = 'Tab: ',
		format_item = function(tab)
			local buffer = vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(tab))
			return Line.get_formated_bufname(buffer)
		end
	}, function(result)
		if result then
			vim.api.nvim_set_current_tabpage(result)
		end
	end)
end)

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local opts = { buffer = ev.buf }

		vim.keymap.set('n', 'grn', vim.lsp.buf.rename, opts)
		vim.keymap.set({ 'n', 'v' }, 'gra', vim.lsp.buf.code_action, opts)
		vim.keymap.set({ 'n', 'v' }, 'grl', vim.lsp.codelens.run, opts)
		vim.keymap.set('n', 'grr', vim.lsp.buf.references, opts)
		vim.keymap.set('n', 'gri', vim.lsp.buf.implementation, opts)
		vim.keymap.set('n', 'gO', vim.lsp.buf.document_symbol, opts)
		vim.keymap.set('n', '<C-s>', vim.lsp.buf.signature_help, opts)

		vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set('n', '<leader>wl', function()
			local dir = vim.lsp.buf.list_workspace_folders()
			vim.ui.select(dir, {
				prompt = 'Workspace Dir: ',
			}, function(result)
				if result then
					vim.api.nvim_set_current_dir(result)
				end
			end)
		end, opts)

		vim.lsp.inlay_hint.enable()

		vim.lsp.codelens.refresh(opts)

		vim.api.nvim_create_autocmd({ 'CursorHold', 'InsertLeave' }, {
			buffer = ev.buf,
			callback = function()
				vim.lsp.codelens.refresh(opts)
			end,
		})

		vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
			buffer = ev.buf,
			callback = function()
				vim.lsp.buf.document_highlight()
			end,
		})

		vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
			buffer = ev.buf,
			callback = function()
				vim.lsp.buf.clear_references()
			end,
		})

		vim.api.nvim_create_autocmd('LspDetach', {
			callback = function()
				vim.lsp.buf.clear_references()
			end,
		})
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
