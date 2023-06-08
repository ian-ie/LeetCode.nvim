local sep = require("plenary.path").path.sep

local default_config = {
	solutionDir = vim.loop.os_homedir() .. sep .. ".leetcode",
    cookieFile = vim.loop.os_homedir() .. sep .. ".lcookie",
	language = "py",
}

return default_config
