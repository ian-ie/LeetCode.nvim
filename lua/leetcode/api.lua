local QUERY = require("leetcode.query")
local config = require("leetcode.config")
local curl = require("plenary.curl")

local request = {}

local function post(query, variables)
	local resp = curl.post(
		config.queryUrl .. "/graphql",
		{ headers = request.headers, body = vim.json.encode({ query = query, variables  = variables or {} }) }
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
    local data = post(QUERY.CODE_TEMPLATE, {titleSlug = slug})
	return data ~= vim.NIL and data["question"] or {}
end

function request.problemContent(slug)
    local data = post(QUERY.PROBLEM_CONTENT, {titleSlug = slug})
	return data ~= vim.NIL and data["question"] or {}
end

return request
