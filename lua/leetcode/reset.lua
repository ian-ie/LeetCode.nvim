local utils = require("leetcode.utils")
local config = require("leetcode.config")
local request = require("leetcode.api")
local M = {}

function M.reset()
	vim.api.nvim_command("LCLogin")
	local qFile = vim.api.nvim_buf_get_name(0)
	if utils.is_in_folder(qFile, config.solutionDir) then
		local name = vim.fn.fnamemodify(qFile, ":t")
		local slug = utils.get_question_slug(name)
		local data = request.questionData(slug)
		for _, _codeTemp in ipairs(data["codeSnippets"]) do
			if _codeTemp.langSlug == utils.langSlugToFileExt[config.language] then
				vim.api.nvim_buf_set_lines(
					vim.api.nvim_get_current_buf(),
					0,
					-1,
					false,
					utils.split_string_to_table(_codeTemp.code)
				)
				break
			end
		end
	end
end

return M
