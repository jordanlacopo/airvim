local M = {}

-- Setup for document highlighting
function M.setup_document_highlight(client, bufnr)
	local status_ok, highlight_supported = pcall(function()
		return client.supports_method("textDocument/documentHighlight")
	end)
	if not status_ok or not highlight_supported then
		return
	end
	local group = "lsp_document_highlight"
	local hl_events = { "CursorHold", "CursorHoldI" }

	local ok, hl_autocmds = pcall(vim.api.nvim_get_autocmds, {
		group = group,
		buffer = bufnr,
		event = hl_events,
	})

	if ok and #hl_autocmds > 0 then
		return
	end

	vim.api.nvim_create_augroup(group, { clear = false })
	vim.api.nvim_create_autocmd(hl_events, {
		group = group,
		buffer = bufnr,
		callback = vim.lsp.buf.document_highlight,
	})
	vim.api.nvim_create_autocmd("CursorMoved", {
		group = group,
		buffer = bufnr,
		callback = vim.lsp.buf.clear_references,
	})
end

return M
