local M = {}

M.user_config = require("leetcode.default_config")

local function register()
	local lcList = require("leetcode.problem").list
	local lcInfo = require("leetcode.info").info
	local lcOpen = require("leetcode.info").info_edge
	local lcToday = require("leetcode.problem").today
    local lcClose = require("leetcode.reset").close
	local lcReset = require("leetcode.reset").reset
	local lcTest = require("leetcode.runner").test
	local lcSubmit = require("leetcode.runner").submit
	local checkCookies = require("leetcode.cookies").checkCookies

	local opts = {}
	vim.api.nvim_create_user_command("LCList", lcList, opts)
	vim.api.nvim_create_user_command("LCInfo", lcInfo, opts)
	vim.api.nvim_create_user_command("LCToday", lcToday, opts)
	vim.api.nvim_create_user_command("LCReset", lcReset, opts)
	vim.api.nvim_create_user_command("LCTest", lcTest, opts)
	vim.api.nvim_create_user_command("LCSubmit", lcSubmit, opts)
	vim.api.nvim_create_user_command("LCLogin", checkCookies, opts)
	vim.api.nvim_create_user_command("LCClose", lcClose, opts)
	vim.api.nvim_create_user_command("LCOpen", lcOpen, opts)
end

M.setup = function(opts)
	M.user_config = vim.tbl_deep_extend("force", M.user_config, opts)
	register()
end

return M
