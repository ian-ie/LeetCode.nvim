local utils = require("leetcode.utils")
local config = require("leetcode.config")
local request = require("leetcode.api")
local M = {}

local cache_slug, cache_content, cache_buf, cache_id

local function display(content)
	if not cache_buf or vim.api.nvim_buf_is_valid(cache_buf) then
		cache_buf = vim.api.nvim_create_buf(true, true)
		content = utils.pad(content)
		vim.api.nvim_buf_set_lines(cache_buf, 0, -1, true, content)

		vim.api.nvim_buf_set_option(cache_buf, "swapfile", false)
		vim.api.nvim_buf_set_option(cache_buf, "modifiable", false)
		vim.api.nvim_buf_set_option(cache_buf, "buftype", "nofile")
		vim.api.nvim_buf_set_option(cache_buf, "buflisted", true)
		vim.api.nvim_buf_set_keymap(cache_buf, "n", "<esc>", "<cmd>hide<CR>", { noremap = true })
		vim.api.nvim_buf_set_keymap(cache_buf, "n", "q", "<cmd>hide<CR>", { noremap = true })
		vim.api.nvim_buf_set_keymap(cache_buf, "v", "q", "<cmd>hide<CR>", { noremap = true })
		-- util.set_resbuf_highlights()
	end

	local width = math.ceil(math.min(vim.o.columns, math.max(90, vim.o.columns - 20)))
	local height = math.ceil(math.min(vim.o.lines, math.max(25, vim.o.lines - 10)))

	local row = math.ceil(vim.o.lines - height) * 0.5 - 1
	local col = math.ceil(vim.o.columns - width) * 0.5 - 1

	vim.api.nvim_open_win(cache_buf, true, {
		border = "rounded",
		style = "minimal",
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
	})
end

local function filterContent(slug)
	local data = request.problemContent(slug)

	cache_id = data["questionId"]

	local content = data["content"]
	if content == vim.NIL then
		return "没有会员权限"
	end
	local entities = {
		{ "amp", "&" },
		{ "apos", "'" },
		{ "#x27", "'" },
		{ "#x2F", "/" },
		{ "#39", "'" },
		{ "#47", "/" },
		{ "lt", "<" },
		{ "gt", ">" },
		{ "nbsp", " " },
		{ "quot", '"' },
	}

	local img_urls = {}
	content = content:gsub("<img.-src=[\"'](.-)[\"'].->", function(url)
		table.insert(img_urls, url)
		return "##IMAGE##"
	end)
	content = string.gsub(content, "<[^>]+>", "")

	for _, url in ipairs(img_urls) do
		content = string.gsub(content, "##IMAGE##", url, 1)
	end

	for _, entity in ipairs(entities) do
		content = string.gsub(content, "&" .. entity[1] .. ";", entity[2])
	end
	return data["questionFrontendId"] .. ". " .. data["title"] .. "\n" .. content
end

function M.info_edge()
	local qFile = vim.api.nvim_buf_get_name(0)
	if utils.is_in_folder(qFile, config.solutionDir) then
		local name = vim.fn.fnamemodify(qFile, ":t")
		local slug = utils.get_question_slug(name)
        local openedge = ":!cmd.exe /C start msedge %s/problems/%s/ > /dev/null 2>&1 &"
		vim.api.nvim_command(string.format(openedge, config["queryUrl"], slug))
	end
end

function M.info()
	vim.api.nvim_command("LCLogin")
	local qFile = vim.api.nvim_buf_get_name(0)
	if utils.is_in_folder(qFile, config.solutionDir) then
		local name = vim.fn.fnamemodify(qFile, ":t")
		local slug = utils.get_question_slug(name)
		if cache_slug ~= slug then
			local content = filterContent(slug)
			cache_content = utils.split_string_to_table(content)
		end

		cache_slug = slug
		display(cache_content)
	end
end

function M.get_question_id()
	return cache_id
end

return M
