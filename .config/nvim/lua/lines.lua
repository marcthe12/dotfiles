---@class Line
local line = {}

---@param buffer integer
---@return string
function line.get_formated_bufname(buffer)
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

---@return string
function line.status()
	local buffer = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
	local buftype = vim.bo[buffer].buftype
	print(buftype)
	if buftype == "terminal" then
		return table.concat({ vim.b[buffer].term_title, vim.api.nvim_buf_get_name(buffer) }, '%=')
	end
	local a = ""
	if vim.opt.ruler then
		a = "%8l:%c%V %8p%%"
	end

	local clients = {}
	for _, client in ipairs(vim.lsp.get_clients()) do
		if client.attached_buffers[buffer] then
			table.insert(clients, client.name)
		end
	end

	local cli = ""
	if #clients ~= 0 then
		cli = "(" .. table.concat(clients, ", ") .. ")"
	end

	return table.concat({
		vim.api.nvim_get_mode().mode:upper(),
		line.get_formated_bufname(buffer),
		"%=",
		vim.bo.filetype,
		cli,
		vim.bo.spelllang,
		vim.bo.fileencoding,
		vim.bo.fileformat,
		a
	}, " ")
end

---@return string
function line.tab()
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
			    line.get_formated_bufname(buffer),
			    " %", tab, 'XX'
		    }
	end, tabs)
	local tabline = table.concat(format, " ")

	return tabline .. '%#TabLineFill#%T'
end

---@return string
function line.column()
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

	if vim.opt.number or vim.opt.relativenumber then
		local linenr = 0
		if vim.v.virtnum == 0 then
			if vim.opt.number and not vim.opt.relativenumber then
				linenr = vim.v.lnum
			elseif not vim.opt.number and vim.opt.relativenumber then
				linenr = vim.v.relnum
			else
				linenr = vim.v.relnum ~= 0 and vim.v.relnum or vim.v.lnum
			end
		end
		local linenum = "%=" .. linenr
		table.insert(col, linenum)
	end

	table.insert(col, "%s")
	return table.concat(col, "")
end

return line
