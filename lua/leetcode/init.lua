local M = {}

M.user_config = require("LeetCode.default_config")

local function register()
	local lcList = require("LeetCode.list")
	local lcInfo = require("LeetCode.info")
	local lcReset = require("LeetCode.reset")
	local lcTest = require("LeetCode.test")
	local lcSubmit = require("LeetCode.submit")
	local checkCookies = require("LeetCode.cookies").checkCookies

	local opts = {}
	vim.api.nvim_create_user_command("lcList", lcList, opts)
	vim.api.nvim_create_user_command("lcInfo", lcInfo, opts)
	vim.api.nvim_create_user_command("lcReset", lcReset, opts)
	vim.api.nvim_create_user_command("lcTest", lcTest, opts)
	vim.api.nvim_create_user_command("lcSubmit", lcSubmit, opts)
	vim.api.nvim_create_user_command("lcCheckCookies", checkCookies, opts)
end

M.setup = function(opts)
	M.user_config = vim.tbl_deep_extend("force", M.user_config, opts)
	register()
end
