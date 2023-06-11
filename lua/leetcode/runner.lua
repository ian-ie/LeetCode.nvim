local request = require("leetcode.api")
local config = require("leetcode.config")
local utils = require("leetcode.utils")
local timer = vim.loop.new_timer()
local M = {}

function M.run(mode)
	vim.api.nvim_command("LCLogin")
end

function M.test()
	M.run(0)
end

function M.submit()
	M.run(1)
end
return M
