local utils = require("leetcode.utils")
local config = require("leetcode.config")
local request = require("leetcode.api")
local M = {}

local inputBuf, resultBuf, questionID

local function splitBuffers(testcase)
	local codeBuf = vim.api.nvim_get_current_buf()

	if inputBuf ~= nil then
		return
	end

	inputBuf = vim.api.nvim_create_buf(false, false)
	resultBuf = vim.api.nvim_create_buf(false, false)

	vim.api.nvim_buf_set_option(inputBuf, "swapfile", false)
	vim.api.nvim_buf_set_option(inputBuf, "buflisted", false)
	vim.api.nvim_buf_set_option(inputBuf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(inputBuf, "modifiable", true)
	vim.api.nvim_buf_set_lines(inputBuf, 0, -1, true, utils.split_string_to_table(testcase))

	vim.api.nvim_buf_set_option(resultBuf, "swapfile", false)
	vim.api.nvim_buf_set_option(resultBuf, "buflisted", false)
	vim.api.nvim_buf_set_option(resultBuf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(resultBuf, "filetype", "Results")

	vim.api.nvim_buf_call(codeBuf, function()
		vim.api.nvim_command("vsp | b " .. inputBuf)
	end)

	vim.api.nvim_buf_call(inputBuf, function()
		vim.api.nvim_command("set nonumber")
		vim.api.nvim_command("set norelativenumber")
		vim.api.nvim_command("sp | b " .. resultBuf)
	end)

	vim.api.nvim_buf_call(codeBuf, function()
		vim.api.nvim_command("vertical resize 130")
	end)

	vim.api.nvim_buf_call(resultBuf, function()
		vim.api.nvim_command("set nonumber")
		vim.api.nvim_command("set norelativenumber")

		local highlights = {
			-- [""] = "TabLineSel IncSearch",
			[".* Error.*"] = "StatusLine",

			[".*Line.*"] = "ErrorMsg",
		}

		local desc = utils.resultTranslate
		local extra_highlights = {
			[desc["res"]] = "TSRainBow6",
			[desc["acc"]] = "DiffAdd",
			[desc["pc"]] = "TSRainBow3",
			[desc["totc"]] = "DiffAdd",
			[desc["f_case_in"]] = "ErrorMsg",
			[desc["wrong_ans_err"]] = "ErrorMsg",
			[desc["failed"]] = "ErrorMsg",
			[desc["testc"] .. ": #\\d\\+"] = "Title",
			[desc["mem"] .. ": .*"] = "Title",
			[desc["rt"] .. ": .*"] = "Title",
			[desc["exp"]] = "Type",
			[desc["out"]] = "Type",
			[desc["exp_out"]] = "Type",
			[desc["stdo"]] = "Type",
			[desc["exe"]] = "St_cwd",
		}

		highlights = vim.tbl_deep_extend("force", highlights, extra_highlights)

		for match, group in pairs(highlights) do
			vim.fn.matchadd(group, match)
		end
	end)
end

function M.reset()
	-- vim.api.nvim_command("LCLogin")

	local qFile = vim.api.nvim_buf_get_name(0)
	if utils.is_in_folder(qFile, config.solutionDir) then
		local name = vim.fn.fnamemodify(qFile, ":t")

		local slug = utils.get_question_slug(name)

		local data = request.codeTemplate(slug)
		questionID = data["questionId"]

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

		splitBuffers(data["sampleTestCase"])
	end
end

function M.get_result_buffer()
	return resultBuf
end

function M.get_input_content()
	return utils.read_buffer_content(inputBuf)
end

function M.get_question_id()
	return questionID
end

function M.close()
	vim.api.nvim_buf_delete(resultBuf, { force = true, unload = true })
	vim.api.nvim_buf_delete(inputBuf, { force = true, unload = true })
	resultBuf = nil
	inputBuf = nil
end
return M
