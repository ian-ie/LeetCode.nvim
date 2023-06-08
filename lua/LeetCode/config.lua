local user_config = require("LeetCode").user_config
local path = require("plenary.path")
local sep = require("plenary.path").path.sep
local cookie_file = path:new(user_config.cookieFile)

cookie_file:touch()
local succ, cookies = pcall(vim.json.decode(), cookie_file:read())

if not succ then
	cookies = {}
end

user_config["queryUrl"] = "https://leetcode.cn/graphql"
local config = vim.tbl_deep_extend("force", user_config, cookies)

return config
