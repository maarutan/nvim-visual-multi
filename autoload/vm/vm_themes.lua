local M = {}

-- Глобальная таблица для хранения всех тем
local themes = {}

-- Регистрация новой темы
function M.register_theme(name, theme_func)
	if themes[name] then
		vim.notify("Theme '" .. name .. "' already exists.", vim.log.levels.WARN)
		return
	end
	themes[name] = theme_func
	vim.notify("Theme '" .. name .. "' registered successfully.", vim.log.levels.INFO)
end

-- Получение темы (используется VimScript)
function M.get_theme(name)
	return themes[name]
end

-- Пример темы
M.register_theme("iceblue", function()
	vim.api.nvim_set_hl(0, "VM_Extend", { bg = "#005f87" })
	vim.api.nvim_set_hl(0, "VM_Cursor", { bg = "#0087af", fg = "#ffffff" })
	vim.api.nvim_set_hl(0, "VM_Insert", { bg = "#4c4e50", fg = "#ffffff" })
	vim.api.nvim_set_hl(0, "VM_Mono", { bg = "#dfaf87", fg = "#000000" })
end)

return M
