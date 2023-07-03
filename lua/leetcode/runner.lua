local request = require("leetcode.api")
local utils = require("leetcode.utils")
local buffers = require("leetcode.reset")
local desc = require("leetcode.utils").resultTranslate
local timer = vim.loop.new_timer()

local M = {}

local function generateOrderID(mode)
	local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
	local code = utils.read_file_contents(vim.fn.expand("%:p"))
	local slug = utils.get_question_slug(file)

	local body = {
		lang = utils.langSlugToFileExt[utils.get_file_extension(vim.fn.expand("%:t"))],
		question_id = buffers.get_question_id(),
		typed_code = code,
	}

	if mode == 1 then
		body.data_input = buffers.get_input_content()
	end
	return request.getOrderId(mode, slug, body)
end

local function displayResult(buf, data, mode)
	local res = {}
	local function insert(output)
		output = output or ""
		table.insert(res, output)
	end

	local function concatTable(t)
		for i = 1, #t do
			insert(t[i])
		end
	end

	if not data and not mode then
		insert(desc["exe"])
	else
		insert(desc["res"])
		insert()

		--test
		if mode == 1 then
			if data["run_success"] then
				if data["correct_answer"] then
					insert(desc["pc"] .. ": " .. data["total_testcases"])
					insert(desc["acc"] .. " ✔️ ")
				else
					insert(
						desc["pc"]
							.. ": "
							.. data["total_correct"]
							.. " / "
							.. desc["failed"]
							.. ": "
							.. data["total_testcases"] - data["total_correct"]
					)
				end
				insert()
				for i = 1, data["total_testcases"] do
					if data["code_answer"][i] ~= data["expected_code_answer"][i] then
						insert(desc["testc"] .. ": #" .. i .. " ❌ ")
						insert(desc["out"] .. ": " .. data["code_answer"][i])
						insert(desc["exp"] .. ": " .. data["expected_code_answer"][i])
						local std = utils.split_string_to_table(data["std_output_list"][i])
						if #std > 0 then
							insert(desc["stdo"] .. ": ")
							concatTable(std)
						end
						insert()
					end
				end
				insert()
				for i = 1, data["total_testcases"] do
					if data["code_answer"][i] == data["expected_code_answer"][i] then
						insert(desc["testc"] .. ": #" .. i .. ": " .. data["code_answer"][i] .. " ✔️ ")
					end
				end
			end
			insert()
			insert(desc["mem"] .. ": " .. data["status_memory"])
			insert(desc["rt"] .. ": " .. data["status_runtime"])
		-- submit
		else
			local succ = data["total_correct"] == data["total_testcases"]
			if succ then
				insert(desc["pc"] .. ": " .. data["total_correct"])
				insert(desc["pc"] .. ": " .. data["total_correct"])
				insert()
				insert(desc["mem"] .. ": " .. data["status_memory"])
				insert(desc["rt"] .. ": " .. data["status_runtime"])
			else
				insert(data["status_msg"])

				if data["run_success"] then
					insert(
						desc["totc"]
							.. ": "
							.. data["total_testcases"]
							.. " / "
							.. desc["failed"]
							.. ": "
							.. data["total_testcases"]
					)
					insert()
				else
					insert(data["runtime_error"])
					insert()
				end
				insert(desc["f_case_in"] .. ": ")
				concatTable(utils.split_string_to_table(data["last_testcase"]))
				insert()
				insert(desc["exp_out"] .. ": " .. data["expected_output"])

				local std = utils.split_string_to_table(data["std_output"])
				if #std > 0 then
					insert(desc["stdo"] .. ": ")
					concatTable(std)
				end
			end
		end
		insert()
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, true, res)
end

local function checkSubmitStatus(buf, id, mode)
	local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
	local slug = utils.get_question_slug(file)

	if id then
		local data = request.getStatus(id, slug)
		if data["state"] == "SUCCESS" then
			timer:stop()
			displayResult(buf, data, mode)
			return
		end
	end
end

function M.run(mode)
	-- vim.api.nvim_command("LCLogin")
	local resultBuf = buffers.get_result_buffer()
	local orderID = generateOrderID(mode)
	displayResult(resultBuf)
	timer:start(
		100,
		1000,
		vim.schedule_wrap(function()
			checkSubmitStatus(resultBuf, orderID, mode)
		end)
	)
end

function M.test()
	M.run(1)
end

function M.submit()
	M.run(2)
end
return M
