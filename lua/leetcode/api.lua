local QUERY = require("leetcode.query")
local config = require("leetcode.config")
local curl = require("plenary.curl")
local utils = require("leetcode.utils")

local request = {}

local function post(query, variables)
	local resp = curl.post(
		config.queryUrl .. "/graphql",
		{ headers = request.headers, body = vim.json.encode({ query = query, variables = variables or {} }) }
	)
	-- vim.pretty_print(resp)
	return vim.json.decode(resp["body"])["data"]
end

request.headers = {
	["Cookie"] = string.format("LEETCODE_SESSION=%s;csrftoken=%s", config.leetcode_session, config.csrf_token),
	["Content-Type"] = "application/json",
	["Accept"] = "application/json",
	["x-csrftoken"] = config.csrf_token,
}

function request.globalData()
	local data = post(QUERY.GLOBAL_DATA)
	return data ~= vim.NIL and data["userStatus"] or {}
end

function request.problemsetQuestionList(keyword)
	local data = post(QUERY.PROBLEMSET_QUESTION_LIST, { searchKeyword = keyword or "" })["problemsetQuestionList"]
	return data ~= vim.NIL and data["questions"] or {}
end

function request.codeTemplate(slug)
	local data = post(QUERY.CODE_TEMPLATE, { titleSlug = slug })
	return data ~= vim.NIL and data["question"] or {}
end

function request.problemContent(slug)
	local data = post(QUERY.PROBLEM_CONTENT, { titleSlug = slug })
	return data ~= vim.NIL and data["question"] or {}
end

function request.todayProblem()
	local data = post(QUERY.TODAY_PROBLEM)
	return data ~= vim.NIL and data["todayRecord"][1]["question"] or {}
end

local request_mode = { { "interpret_solution", "interpret_id" }, { "submit", "submission_id" } }

function request.getOrderId(mode, slug, body)
	local suffixUrl = "/problems/" .. slug .. "/" .. request_mode[mode][1] .. "/"
	local extra_headers = {
		["Referer"] = config.queryUrl .. "/problems/" .. slug .. "/",
	}

	local new_headers = vim.tbl_deep_extend("force", request.headers, extra_headers)
	local resp = curl.post(config.queryUrl .. suffixUrl, { headers = new_headers, body = vim.json.encode(body) })
	local data = vim.json.decode(resp["body"])
	return data ~= vim.NIL and data[request_mode[mode][2]] or nil
end

function request.getStatus(id, slug)
	local suffixUrl = "/submissions/detail/" .. id .. "/check"

	local extra_headers = {
		["Referer"] = config.queryUrl .. "/problems/" .. slug .. "/",
	}

	local new_headers = vim.tbl_deep_extend("force", request.headers, extra_headers)
	local resp = curl.get(config.queryUrl .. suffixUrl, { headers = new_headers })
	local data = vim.json.decode(resp["body"])
	return data ~= vim.NIL and data or {}
end
return request
