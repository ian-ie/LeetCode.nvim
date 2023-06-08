local config = require("LeetCode.config")
local curl = require("plenary.curl")

local request = {}

local QUERY_GLOBAL_DATA = [[
     query globalData {
      userStatus {
        isSignedIn
        username
      }
    }
]]

local function post(query)
	local resp = curl.post(config.queryUrl, { headers = request.headers, body = vim.json.encode({ query = query }) })
	return vim.json.decode(resp["body"])
end

request.headers = {
	["Cookie"] = string.format("LEETCODE_SESSION=%s;csrftoken=%s", config.leetcode_session, config.csrf_token),
	["Content-Type"] = "application/json",
	["Accept"] = "application/json",
	["x-csrftoken"] = config.csrf_token,
	["Referer"] = config.queryUrl,
}

function request.globalData()
	local data = post(QUERY_GLOBAL_DATA)
	return data["userStatus"]
end

return request
