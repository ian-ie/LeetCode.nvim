local M = {}
function M.openFileInBuffer(filepath)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(buf) == filepath then
			-- 如果文件已经打开在缓冲区中，则跳转到该缓冲区
			vim.api.nvim_set_current_buf(buf)
			return
		end
	end
	vim.api.nvim_command("edit " .. vim.fn.fnameescape(filepath))
end

return M
