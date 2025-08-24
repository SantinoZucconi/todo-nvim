local lib = require("lib")
local task_status = require("task_status")
local kanban = {
    buffers = {},
    windows = {}
}

local function create_kanban_column(buf, title, tasks, width, height, row, col)
    for i, task in ipairs(tasks) do
        if (i == 1) then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {task})
        else
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, {task})
        end
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, {string.rep("─", width)})
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

    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf})
    vim.api.nvim_set_option_value("wrap", true, { win = win })
    vim.api.nvim_set_option_value("linebreak", true, { win = win })
    vim.api.nvim_set_current_win(win)
    return win
end

local function create_buffer(title)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, vim.fn.tempname() .. "-" .. title)
    return buf
end

local close_fn = function()
    lib.close_win_if_valid(kanban.windows[task_status.ToDo])
    lib.close_win_if_valid(kanban.windows[task_status.InProgress])
    lib.close_win_if_valid(kanban.windows[task_status.Done])
    lib.close_buf_if_valid(kanban.windows[task_status.ToDo])
    lib.close_buf_if_valid(kanban.windows[task_status.InProgress])
    lib.close_buf_if_valid(kanban.windows[task_status.Done])
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
        kanban.buffers[state] = create_buffer(state)
        local win = create_kanban_column(
            kanban.buffers[state],
            state,
            col_tasks[state],
            col_width,
            board_height,
            start_row,
            start_col + (i-1)* (col_width + 2)
        )
        kanban.windows[state] = win
    end
    for _, buf in pairs(kanban.buffers) do
        vim.keymap.set("n", "q", close_fn, { buffer = buf })
    end
    vim.api.nvim_create_autocmd("WinClosed", {
        callback = close_fn
    })
end

return kanban
