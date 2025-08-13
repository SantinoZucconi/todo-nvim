local create = require("create_tasks")
local list = require("list_tasks")
local M = {}

M.setup = function()
    vim.keymap.set("n", "<leader>tt", function()
        create.add_task()
    end, { desc = "Test keymap mi_plugin" })
    vim.keymap.set("n", "<leader>lt", function()
        list.list_tasks()
    end, { desc = "Test keymap mi_plugin" })
end

return M
