-- backports from nightly to 0.10

-- LSP Stuff
vim.keymap.set('n', 'grn', function()
	vim.lsp.buf.rename()
end)

vim.keymap.set({ 'n', 'x' }, 'gra', function()
	vim.lsp.buf.code_action()
end)

vim.keymap.set('n', 'grr', function()
	vim.lsp.buf.references()
end)

vim.keymap.set('n', 'gri', function()
	vim.lsp.buf.implementation()
end)

vim.keymap.set('n', 'gO', function()
	vim.lsp.buf.document_symbol()
end)

vim.keymap.set({ 'i', 's' }, '<C-S>', function()
	vim.lsp.buf.signature_help()
end)

-- Terminal AutoSetup
vim.api.nvim_create_autocmd('TermOpen', {
	desc = 'Default settings for :terminal buffers',
	callback = function()
		vim.bo.modifiable = false
		vim.bo.undolevels = -1
		vim.bo.scrollback = vim.o.scrollback < 0 and 10000 or math.max(1, vim.o.scrollback)
		vim.bo.textwidth = 0
		vim.wo[0][0].wrap = false
		vim.wo[0][0].list = false
		vim.wo[0][0].number = false
		vim.wo[0][0].relativenumber = false
		vim.wo[0][0].signcolumn = 'no'
		vim.wo[0][0].foldcolumn = '0'

		-- This is gross. Proper list options support when?
		local winhl = vim.o.winhighlight
		if winhl ~= '' then
			winhl = winhl .. ','
		end
		vim.wo[0][0].winhighlight = winhl .. 'StatusLine:StatusLineTerm,StatusLineNC:StatusLineTermNC'
	end,
})

-- Vim Unpaired
-- ]<Space> and [<Space> not ported

--- Execute a command and print errors without a stacktrace.
--- @param opts table Arguments to |nvim_cmd()|
local function cmd(opts)
	local ok, err = pcall(vim.api.nvim_cmd, opts, {})
	if not ok then
		vim.api.nvim_err_writeln(err:sub(#'Vim:' + 1))
	end
end

-- Quickfix mappings
vim.keymap.set('n', '[q', function()
	cmd({ cmd = 'cprevious', count = vim.v.count1 })
end, { desc = ':cprevious' })

vim.keymap.set('n', ']q', function()
	cmd({ cmd = 'cnext', count = vim.v.count1 })
end, { desc = ':cnext' })

vim.keymap.set('n', '[Q', function()
	cmd({ cmd = 'crewind', count = vim.v.count ~= 0 and vim.v.count or nil })
end, { desc = ':crewind' })

vim.keymap.set('n', ']Q', function()
	cmd({ cmd = 'clast', count = vim.v.count ~= 0 and vim.v.count or nil })
end, { desc = ':clast' })

vim.keymap.set('n', '[<C-Q>', function()
	cmd({ cmd = 'cpfile', count = vim.v.count1 })
end, { desc = ':cpfile' })

vim.keymap.set('n', ']<C-Q>', function()
	cmd({ cmd = 'cnfile', count = vim.v.count1 })
end, { desc = ':cnfile' })

-- Location list mappings
vim.keymap.set('n', '[l', function()
	cmd({ cmd = 'lprevious', count = vim.v.count1 })
end, { desc = ':lprevious' })

vim.keymap.set('n', ']l', function()
	cmd({ cmd = 'lnext', count = vim.v.count1 })
end, { desc = ':lnext' })

vim.keymap.set('n', '[L', function()
	cmd({ cmd = 'lrewind', count = vim.v.count ~= 0 and vim.v.count or nil })
end, { desc = ':lrewind' })

vim.keymap.set('n', ']L', function()
	cmd({ cmd = 'llast', count = vim.v.count ~= 0 and vim.v.count or nil })
end, { desc = ':llast' })

vim.keymap.set('n', '[<C-L>', function()
	cmd({ cmd = 'lpfile', count = vim.v.count1 })
end, { desc = ':lpfile' })

vim.keymap.set('n', ']<C-L>', function()
	cmd({ cmd = 'lnfile', count = vim.v.count1 })
end, { desc = ':lnfile' })

-- Argument list
vim.keymap.set('n', '[a', function()
	cmd({ cmd = 'previous', count = vim.v.count1 })
end, { desc = ':previous' })

vim.keymap.set('n', ']a', function()
	-- count doesn't work with :next, must use range. See #30641.
	cmd({ cmd = 'next', range = { vim.v.count1 } })
end, { desc = ':next' })

vim.keymap.set('n', '[A', function()
	if vim.v.count ~= 0 then
		cmd({ cmd = 'argument', count = vim.v.count })
	else
		cmd({ cmd = 'rewind' })
	end
end, { desc = ':rewind' })

vim.keymap.set('n', ']A', function()
	if vim.v.count ~= 0 then
		cmd({ cmd = 'argument', count = vim.v.count })
	else
		cmd({ cmd = 'last' })
	end
end, { desc = ':last' })

-- Tags
vim.keymap.set('n', '[t', function()
	-- count doesn't work with :tprevious, must use range. See #30641.
	cmd({ cmd = 'tprevious', range = { vim.v.count1 } })
end, { desc = ':tprevious' })

vim.keymap.set('n', ']t', function()
	-- count doesn't work with :tnext, must use range. See #30641.
	cmd({ cmd = 'tnext', range = { vim.v.count1 } })
end, { desc = ':tnext' })

vim.keymap.set('n', '[T', function()
	-- count doesn't work with :trewind, must use range. See #30641.
	cmd({ cmd = 'trewind', range = vim.v.count ~= 0 and { vim.v.count } or nil })
end, { desc = ':trewind' })

vim.keymap.set('n', ']T', function()
	-- :tlast does not accept a count, so use :trewind if count given
	if vim.v.count ~= 0 then
		cmd({ cmd = 'trewind', range = { vim.v.count } })
	else
		cmd({ cmd = 'tlast' })
	end
end, { desc = ':tlast' })

vim.keymap.set('n', '[<C-T>', function()
	-- count doesn't work with :ptprevious, must use range. See #30641.
	cmd({ cmd = 'ptprevious', range = { vim.v.count1 } })
end, { desc = ' :ptprevious' })

vim.keymap.set('n', ']<C-T>', function()
	-- count doesn't work with :ptnext, must use range. See #30641.
	cmd({ cmd = 'ptnext', range = { vim.v.count1 } })
end, { desc = ':ptnext' })

-- Buffers
vim.keymap.set('n', '[b', function()
	cmd({ cmd = 'bprevious', count = vim.v.count1 })
end, { desc = ':bprevious' })

vim.keymap.set('n', ']b', function()
	cmd({ cmd = 'bnext', count = vim.v.count1 })
end, { desc = ':bnext' })

vim.keymap.set('n', '[B', function()
	if vim.v.count ~= 0 then
		cmd({ cmd = 'buffer', count = vim.v.count })
	else
		cmd({ cmd = 'brewind' })
	end
end, { desc = ':brewind' })

vim.keymap.set('n', ']B', function()
	if vim.v.count ~= 0 then
		cmd({ cmd = 'buffer', count = vim.v.count })
	else
		cmd({ cmd = 'blast' })
	end
end, { desc = ':blast' })
