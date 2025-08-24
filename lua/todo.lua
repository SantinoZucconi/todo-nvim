local create = require("create_tasks")
local list = require("list_tasks")
local kanban = require("create_kanban")
local highlights = require("highlights")
highlights.setup()
local M = {}

M.setup = function()
    vim.keymap.set("n", "<leader>tt", function()
        create.add_task()
    end, { desc = "Test keymap mi_plugin" })
    vim.keymap.set("n", "<leader>lt", function()
        list.list_tasks()
    end, { desc = "Test keymap mi_plugin" })
    vim.keymap.set("n", "<leader>kt", function()
        kanban.open_kanban_board()
    end, { desc = "Test keymap mi_plugin" })
end

return M
