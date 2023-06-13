local request = require("leetcode.api")
local path = require("plenary.path")
local sep = require("plenary.path").path.sep
local config = require("leetcode.config")
local utils = require("leetcode.utils")
local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local make_entry = require("telescope.make_entry")
local entry_display = require("telescope.pickers.entry_display")
local opts = {}

local function filter_problems()
	return function(keyword)
		return request.problemsetQuestionList(keyword)
	end
end

local function update_status(sts, is_paid)
	if sts == vim.NIL and not is_paid then
		return " "
	end

	local statuses = {
		ac = "✔️",
		notac = "❌",
		AC = "✔️",
		TRIED = "❌",
	}
	local s = sts ~= vim.NIL and statuses[sts] or ""
	local c = is_paid and "👑" or ""
	return s .. c
end

local function gen_from_problems()
	local displayer = entry_display.create({
		separator  = "",
		items = {
			{ with = 6 },
			{ with = 6 },
			{ with = 60 },
			{ with = 8 },
		},
	})

	local make_display = function(entry)
		return displayer({
			{ entry.value.frontendQuestionId, "Number" },
			{ update_status(entry.value.status, entry.value.paid_only), "Status" },
			{ entry.value.titleCn, "Title" },
			{ entry.value.difficulty, "Difficulty" },
		})
	end

	return function(o)
		local entry = {
			display = make_display,
			value = {
				frontendQuestionId = o.frontendQuestionId,
				status = o.status,
				titleCn = o.titleCn,
				slug = o.titleSlug,
				difficulty = o.difficulty,
				paid_only = o.paidOnly,
			},
			ordinal = string.format("%s\t%s\t%s\t%s", o.frontendQuestionId, o.status, o.titleCn, o.difficulty),
		}
		return make_entry.set_default_entry_mt(entry, opts)
	end
end

local function touchProblemFile(problem)
	local slug = string.format("%d.%s", problem["frontendQuestionId"], problem["slug"])

	local sDir = path:new(config.solutionDir)
	if not sDir:exists() then
		sDir:makdir()
	end

	local pFile = path:new(config.solutionDir .. sep .. slug .. "." .. config.language)
	if not pFile:exists() then
		pFile:touch()
	end

	utils.openFileInBuffer(pFile:absolute())
	vim.api.nvim_command("LCReset")
	vim.api.nvim_command("LCInfo")
end

local function select_problem(prompt_bufnr)
	actions.close(prompt_bufnr)
	local problem = action_state.get_selected_entry()["value"]
    touchProblemFile(problem)
end

function M.list()
	vim.api.nvim_command("LCLogin")
	pickers
		.new(opts, {
			prompt_title = "problems",
			finder = finders.new_dynamic({
				fn = filter_problems(),
				entry_maker = gen_from_problems(),
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(_, map)
				map("i", "<CR>", select_problem)
				map("n", "<CR>", select_problem)
				return true
			end,
		})
		:find()
end

function M.today()
    vim.api.nvim_command("LCLogin")
    local problem = request.todayProblem()
    touchProblemFile(problem)
end

return M
