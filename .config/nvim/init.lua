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


---@param buffer integer
---@return string
local function get_formated_bufname(buffer)
	buffer = buffer or 0

	local name = vim.api.nvim_buf_get_name(buffer)
	local buftype = vim.bo[buffer].buftype
	if buftype == "terminal" then
		name = vim.b[buffer].term_title
	else
		if #name == 0 then
			name = '[No Name] (' .. (buftype or vim.bo[buffer].filetype) .. ')'
		end
		local modified = vim.bo[buffer].modified and '[+]' or ""
		local readonly = vim.bo[buffer].readonly and '[RO]' or ""
		name = name .. modified .. readonly
	end

	return name
end

---@class Line
Line = {
	---@return string
	status = function()
		local buffer = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
		local buftype = vim.bo[buffer].buftype
		print(buftype)
		if buftype == "terminal" then
			return table.concat({ vim.b[buffer].term_title, vim.api.nvim_buf_get_name(buffer) }, '%=')
		end
		local a = ""
		if vim.opt.ruler:get() then
			a = "%8l:%c%V %8p%%"
		end

		local clients = {}
		for _, client in ipairs(vim.lsp.get_clients()) do
			if client.attached_buffers[buffer] then
				table.insert(clients, client.name)
			end
		end

		return table.concat({
			vim.api.nvim_get_mode().mode:upper(),
			get_formated_bufname(buffer),
			"%=",
			vim.bo.filetype,
			"(" .. table.concat(clients, ", ") .. ")",
			vim.bo.spelllang,
			vim.bo.fileencoding,
			vim.bo.fileformat,
			a
		}, " ")
	end,

	---@return string
	tab = function()
		local tabs = vim.api.nvim_list_tabpages()
		local format = vim.tbl_map(function(tab)
			local str = ""
			if tab == vim.api.nvim_get_current_tabpage() then
				str = '%#TabLineSel#'
			else
				str = '%#TabLine#'
			end
			local buffer = vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(tab))
			return
			    table.concat {
				    str,
				    "%", tab, 'T',
				    get_formated_bufname(buffer),
				    " %", tab, 'XX'
			    }
		end, tabs)
		local tabline = table.concat(format, " ")

		return tabline .. '%#TabLineFill#%T'
	end,

	---@return string
	column = function()
		local col = {}
		if vim.opt.foldenable:get() then
			local foldchar = " "
			local hl = vim.fn.line(".") == vim.v.lnum and "CursorLineFold#" or "FoldColumn#"
			if vim.v.virtnum == 0 and vim.fn.foldlevel(vim.v.lnum)
			    and vim.fn.foldlevel(vim.v.lnum) > vim.fn.foldlevel(vim.v.lnum - 1) then
				foldchar = vim.fn.foldclosed(vim.v.lnum) == -1 and "⌵" or "›"
			end

			foldchar = "%#" .. hl .. foldchar .. "%*"
			table.insert(col, foldchar)
		end

		if vim.opt.number:get() or vim.opt.relativenumber:get() then
			local linenr = " "
			if vim.v.virtnum == 0 then
				if vim.opt.number:get() and not vim.opt.relativenumber:get() then
					linenr = vim.v.lnum
				elseif not vim.opt.number:get() and vim.opt.relativenumber:get() then
					linenr = vim.v.relnum
				else
					linenr = vim.v.relnum ~= 0 and vim.v.relnum or vim.v.lnum
				end
			end
			linenr = "%=" .. linenr
			table.insert(col, linenr)
		end

		table.insert(col, "%s")
		return table.concat(col, "")
	end
}

require 'nvim-treesitter.configs'.setup {
	highlight = {
		enable = true,
	},
	indent = { enable = true },
	auto_install = true,
}

local set = require 'set'

---@param dir string
function Filepicker(dir)
	vim.fs.normalize(dir)
	local function action(result)
		if result[2] == "directory" then
			Filepicker(result[1])
		elseif result[2] == "link"
		then
			action({ result[3], result[4] })
		else
			vim.cmd("edit " .. result[1])
		end
	end
	local function format(tbl)
		if tbl[2] == "directory" then
			return tbl[1] .. "/"
		elseif tbl[2] == "link" then
			return tbl[1] .. " -> " .. format({ tbl[3], tbl[4] })
		else
			return tbl[1]
		end
	end
	local file_iter = vim.iter(vim.fs.dir(dir, { depth = 1 }))
	local files = file_iter:totable()
	table.insert(files, 1, { "..", "link" })
	files = vim.tbl_map(function(tbl)
		if tbl[2] == "link" then
			local path = vim.fs.joinpath(dir, tbl[1])
			tbl[#tbl + 1] = vim.uv.fs_realpath(path)
			if tbl[3] then
				tbl[#tbl + 1] = vim.uv.fs_stat(tbl[3]).type
			else
				tbl[#tbl + 1] = "broken"
			end
		end
		return tbl
	end, files)
	files = vim.tbl_filter(function(tbl)
		local valid = set:new { "file", "directory" }
		if tbl[2] == "link" then
			return valid:has(tbl[4])
		else
			return valid:has(tbl[2])
		end
	end, files)
	vim.ui.select(files, {
		prompt = 'Open: ',
		format_item = format
	}, function(result)
		if result then
			result[1] = vim.fs.joinpath(dir, result[1])
			action(result)
		end
	end)
end

vim.keymap.set('n', '<leader>o', function()
	Filepicker(vim.fn.getcwd())
end)

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

require("conform").setup {
	formatters_by_ft = {
		python = { "isort", "black" },
	},
}

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
	require("conform").format({ async = true, lsp_format = "fallback", range = range })
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
		format_item = get_formated_bufname
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
			return get_formated_bufname(buffer)
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

		vim.lsp.codelens.refresh({ bufnr = ev.buf })

		vim.api.nvim_create_autocmd({ 'CursorHold', 'InsertLeave' }, {
			buffer = ev.buf,
			callback = function()
				vim.lsp.codelens.refresh({ bufnr = ev.buf })
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
		require('cmp_nvim_lsp').default_capabilities()
	)
	local config = require("lspconfig")
	require("lspconfig")[server_name].setup(settings)
end


require('mason').setup {}
require('mason-lspconfig').setup {
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
						codelenses ={
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

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
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
})

-- require("fidget").setup {}
