local M = {}

M.langSlugToFileExt = {
  ["cpp"] = "cpp",
  ["java"] = "java",
  ["py"] = "python3",
  ["c"] = "c",
  ["cs"] = "csharp",
  ["js"] = "javascript",
  ["rb"] = "ruby",
  ["swift"] = "swift",
  ["go"] = "golang",
  ["scala"] = "scala",
  ["kt"] = "kotlin",
  ["rs"] = "rust",
  ["php"] = "php",
  ["ts"] = "typescript",
  ["rkt"] = "racket",
  ["erl"] = "erlang",
  ["ex"] = "elixir",
  ["dart"] = "dart",
}

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

function M.is_in_folder(file, folder)
  return string.sub(file, 1, string.len(folder)) == folder
end

function M.get_question_slug(file)
  return string.gsub(string.gsub(file, "^%d+%.", ""), "%.[^.]+$", "")
end

function M.split_string_to_table(str)
  local lines = {}
  for line in str:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end
  return lines
end

return M
