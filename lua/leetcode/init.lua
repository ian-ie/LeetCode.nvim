local M = {}

M.user_config = require("leetcode.default_config")

local function register()
	local lcList = require("leetcode.list").list
	local lcInfo = require("leetcode.info")
	local lcReset = require("leetcode.reset")
	local lcTest = require("leetcode.test")
	local lcSubmit = require("leetcode.submit")
	local checkCookies = require("leetcode.cookies").checkCookies

	local opts = {}
	vim.api.nvim_create_user_command("LCList", lcList, opts)
	-- vim.api.nvim_create_user_command("LCInfo", lcInfo, opts)
	-- vim.api.nvim_create_user_command("LCReset", lcReset, opts)
	-- vim.api.nvim_create_user_command("LCTest", lcTest, opts)
	-- vim.api.nvim_create_user_command("LCSubmit", lcSubmit, opts)
	vim.api.nvim_create_user_command("LCLogin", checkCookies, opts)
end

M.setup = function(opts)
	M.user_config = vim.tbl_deep_extend("force", M.user_config, opts)
	register()
end

return M
