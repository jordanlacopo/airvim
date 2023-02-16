local M = {}
M.methods = {}

local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end
M.methods.has_words_before = has_words_before

-- import nvim-cmp plugin safely
local cmp_status, cmp = pcall(require, "cmp")
if not cmp_status then
	return
end

-- import luasnip plugin safely
local luasnip_status, luasnip = pcall(require, "luasnip")
if not luasnip_status then
	return
end

-- import lspkind plugin safely
local lspkind_status, lspkind = pcall(require, "lspkind")
if not lspkind_status then
	return
end

-- load vs-code like snippets from plugins (e.g. friendly-snippets)
require("luasnip/loaders/from_vscode").lazy_load()

vim.opt.completeopt = "menu,menuone,noselect"

-- Local variables
local cmp_window = require("cmp.config.window")
local cmp_mapping = require("cmp.config.mapping")
local status_cmp_ok, cmp_types = pcall(require, "cmp.types.cmp")
if not status_cmp_ok then
	return
end
local ConfirmBehavior = cmp_types.ConfirmBehavior
local SelectBehavior = cmp_types.SelectBehavior

--CMP SETUP
cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp_mapping.preset.insert({
		["<C-k>"] = cmp_mapping(cmp_mapping.select_prev_item(), { "i", "c" }),
		["<C-j>"] = cmp_mapping(cmp_mapping.select_next_item(), { "i", "c" }),
		["<Down>"] = cmp_mapping(cmp_mapping.select_next_item({ behavior = SelectBehavior.Select }), { "i" }),
		["<Up>"] = cmp_mapping(cmp_mapping.select_prev_item({ behavior = SelectBehavior.Select }), { "i" }),
		["<C-d>"] = cmp_mapping.scroll_docs(-4),
		["<C-f>"] = cmp_mapping.scroll_docs(4),
		["<C-y>"] = cmp_mapping({
			i = cmp_mapping.confirm({ behavior = ConfirmBehavior.Replace, select = false }),
			c = function(fallback)
				if cmp.visible() then
					cmp.confirm({ behavior = ConfirmBehavior.Replace, select = false })
				else
					fallback()
				end
			end,
		}),
		["<Tab>"] = cmp_mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
				--elseif jumpable(1) then
				--luasnip.jump(1)
			elseif has_words_before() then
				cmp.complete()
				fallback()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp_mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
		["<C-Space>"] = cmp_mapping.complete(),
		["<C-e>"] = cmp_mapping.abort(),
	}),
	-- sources for autocompletion
	sources = cmp.config.sources({
		{ name = "nvim_lsp" }, -- lsp
		{ name = "luasnip" }, -- snippets
		{ name = "buffer" }, -- text within current buffer
		{ name = "path" }, -- file system paths
	}),
	window = {
		completion = cmp_window.bordered(),
		documentation = cmp_window.bordered(),
	},
	-- configure lspkind for vs-code like icons
	formatting = {
		format = lspkind.cmp_format({
			maxwidth = 50,
			ellipsis_char = "...",
		}),
	},
})
