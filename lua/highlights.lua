local highlights = {}
local task_status = require("task_status")

function highlights.setup()
    vim.api.nvim_set_hl(0, task_status.ToDo.nameid, { fg = "#ff5556", bold = true })
    vim.api.nvim_set_hl(0, task_status.InProgress.nameid, { fg = "#f1fa8c", bold = true })
    vim.api.nvim_set_hl(0, task_status.Done.nameid, { fg = "#50fa7b", bold = true })
end

return highlights
