local request = require("leetcode.api")
local config = require("leetcode.config")
local path = require("plenary.path")
local cookie_file = path:new(config.cookieFile)
local cookie_field = { "leetcode_session", "csrf_token" }
local dir = path:new(config.solutionDir)
local M = {}

local status = false
local username

local function savaCookieToFile()
	local new_cookies = {}
	for _, field in ipairs(cookie_field) do
		local input = vim.fn.input("Enter cookie for " .. field .. ":")
		if input then
			new_cookies[field] = input
		end
	end
	local data = vim.json.encode(new_cookies)
	cookie_file:write(data, "w")
	print("\t\nCookies已保存,请重启Neovim以加载")
end

local function checkPreconditions()
	if not dir:exists() then
		dir:mkdir()
		-- print("solution目录已创建:" .. dir)
	end

	if not cookie_file:exists() then
		cookie_file:touch()
		-- print("Cookie文件已创建:" .. cookie_file)
	end

	local success = pcall(vim.json.decode, cookie_file:read())

	if not success then
		savaCookieToFile()
	end
	return success
end

local function tryLogin(headers)
	local user_status = request.globalData(headers)
	status = user_status["isSignedIn"]
	username = user_status["username"]
	if not status then
		print("\t\nCookies无效,请重新输入")
		savaCookieToFile()
	else
		print(username .. "已登录")
	end
end

function M.checkCookies()
	if status then
		return
	end
	if checkPreconditions() then
		tryLogin()
	end
end

return M
