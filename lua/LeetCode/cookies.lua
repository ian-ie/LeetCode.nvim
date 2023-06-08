local request = require("LeetCode.api")
local curl = require("plenary.curl")
local config = require("LeetCode.config")
local path = require("plenary.path")
local sep = path.path.sep
local cookie_file = path:new(config.cookieFile)
local cookie_field = { "leetcode_session", "csrf_token" }
local dir = path:new(config.solutionDir)
local M = {}

local status = false
local cookies = {}
local username

local function savaCookieToFile()
	local new_cookies = {}
	for _, field in ipairs(cookie_field) do
		local input = vim.fn.input("Enter cookie for" .. field .. ":")
		if input then
			new_cookies[field] = input
		end
	end
	cookies = new_cookies
	local data = vim.json.encode(new_cookies)
	cookie_file:write(data, "w")
	print("\n\nCookies已保存，请重启Neovim")
	return true
end

local function checkPreconditions()
	if not dir:exists() then
		dir:mkdir()
		print("solution目录已创建:" .. dir)
	end

	if not cookie_file:exists() then
		cookie_file:touch()
		print("Cookie文件已创建:" .. cookie_file)
	end

	local success
	success, cookies = pcall(vim.json.decode, cookie_file:read())

	if not success then
		savaCookieToFile()
	end
end

function M.checkCookies()
	if status then
		return
	end
	checkPreconditions()
    local user_status = request.globalData()
    status = user_status["isSignedIn"]
    username = user_status["username"]
    if not status then
        print("\nCookies已过期")
        savaCookieToFile()
        M.checkCookies()
    else
        print(username.."已登录")
    end

end
