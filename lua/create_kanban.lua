local lib = require("lib")
local config = require("config")
local task_status = require("task_status")
local kanban = {}

local function create_kanban_column(title, tasks, width, height, row, col)
    local buf = vim.api.nvim_create_buf(false, true)
    for _, task in ipairs(tasks) do
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, {task})
    end

    local win = vim.api.nvim_open_win(buf, false, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = title,
        title_pos = "center"
    })

    return buf, win
end

function kanban.open_kanban_board()
    local all_tasks = lib.open_task_file()
    local total_width = vim.o.columns
    local total_height = vim.o.lines

    local board_width = math.floor(total_width * 0.7)
    local board_height = math.floor(total_height * 0.7)

    local col_width = math.floor(board_width / 3)
    local start_row = math.floor((total_height - board_height) / 2)
    local start_col = math.floor((total_width - board_width) / 2)

    local states = {task_status.ToDo, task_status.InProgress, task_status.Done}
    local col_tasks = {
        [task_status.ToDo] = {},
        [task_status.InProgress] = {},
        [task_status.Done] = {}
    }

    for _, t in ipairs(all_tasks) do
        table.insert(col_tasks[t.status] or col_tasks[task_status.ToDo], t.title)
    end

    for i, state in ipairs(states) do
        create_kanban_column(
            state,
            col_tasks[state],
            col_width,
            board_height,
            start_row,
            start_col + (i-1)* (col_width + 2)
        )
    end
end

return kanban
