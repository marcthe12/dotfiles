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

vim.o.completeopt = "menuone,noselect,popup,fuzzy"
vim.o.showtabline = 2

vim.cmd.colorscheme 'retrobox'

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

require 'mason'.setup {}

vim.api.nvim_create_autocmd('FileType', {
	callback = function(args)
		pcall(vim.treesitter.start, args.buf, args.match)
	end
})

vim.keymap.set('n', '<leader>q', function()
	vim.diagnostic.setloclist()
end)

vim.diagnostic.config {
	virtual_lines = true,
}

vim.keymap.set('n', '<leader>f', function()
	vim.lsp.buf.format { async = true }
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
	vim.lsp.buf.format { async = true, range = range }
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

		if not client then
			return
		end

		if client:supports_method('textDocument/inlayHint') then
			vim.lsp.inlay_hint.enable()
		end

		if client:supports_method('textDocument/completion') then
			local chars = {}
			for i = 32, 126 do
				table.insert(chars, string.char(i))
			end
			client.server_capabilities.completionProvider.triggerCharacters = chars
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end

		if client:supports_method('textDocument/documentHighlight') then
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

		if client:supports_method('textDocument/foldingRange') then
			local win = vim.api.nvim_get_current_win()
			vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
		end

		if client:supports_method('textDocument/codelens') then
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

vim.lsp.config('*', {
	root_markers = { '.git' }
})

vim.lsp.enable {
	"lua_ls",
	"gopls",
	"clangd",
	"mesonlsp",
	"ts_ls",
	-- "eslint",
	"html",
	"cssls",
	"jsonls",
	"ruff",
	-- "pyright",
}
