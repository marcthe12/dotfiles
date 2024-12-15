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
	local window = vim.g.statusline_winid
	local fillchar
	if window == vim.api.nvim_get_current_win() then
		fillchar = vim.opt.fillchars:get()["stl"]
	else
		fillchar = vim.opt.fillchars:get()["stlnc"]
	end

	if fillchar == nil then
		fillchar = " "
	end

	local buffer = vim.api.nvim_win_get_buf(window)
	local buftype = vim.bo[buffer].buftype


	if buftype == "terminal" then
		return table.concat({ vim.b[buffer].term_title, vim.api.nvim_buf_get_name(buffer) }, '%=')
	end

	if vim.bo[buffer].filetype == "netrw"
	then
		return "%f"
	end

	--	return '%=%-11.S%k%-14.(%l,%c%V%) %P'
	local ruler = ""
	if vim.o.ruler then
		ruler = vim.o.rulerformat
		if #ruler == 0 then
			ruler = "%-14.(%l:%c%V%)" .. fillchar .. "%P"
		end
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
		'%<%f',
		'%h%w%m%r',
		"%=",
		vim.bo[buffer].filetype,
		cli,
		vim.bo[buffer].spelllang,
		vim.bo[buffer].fileencoding,
		vim.bo[buffer].fileformat,
		'%-12.k',
		'%S',
		ruler
	}, fillchar)
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

return line
