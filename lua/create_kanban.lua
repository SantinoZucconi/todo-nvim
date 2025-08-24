local lib = require("lib")
local task_status = require("task_status")
local kanban = {
    buffers = {},
    windows = {}
}

local ns_kanban = vim.api.nvim_create_namespace("kanban")

vim.api.nvim_set_hl(0, "separator", { fg = "#444444" })

local function create_kanban_column(buf, state, tasks, width, height, row, col)
    local sep = string.rep("─", width)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {sep})
    local line_nr = 0
    vim.api.nvim_buf_set_extmark(buf, ns_kanban, line_nr, 0, {
        hl_group = "separator",
        end_col = #sep
    })
    for _, task in pairs(tasks) do
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, {task})
        line_nr = vim.api.nvim_buf_line_count(buf) - 1
        local line_text = vim.api.nvim_buf_get_lines(buf, line_nr, line_nr+1, false)[1]
        vim.api.nvim_buf_set_extmark(buf, ns_kanban, line_nr, 0, {
            hl_group = state.nameid,
            end_col = #line_text
        })

        vim.api.nvim_buf_set_lines(buf, -1, -1, false, {sep})
        line_nr = vim.api.nvim_buf_line_count(buf) - 1
        vim.api.nvim_buf_set_extmark(buf, ns_kanban, line_nr, 0, {
            hl_group = "separator",
            end_col = #sep
        })
    end

    local win = vim.api.nvim_open_win(buf, false, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = state.title,
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
        [task_status.ToDo.title] = {},
        [task_status.InProgress.title] = {},
        [task_status.Done.title] = {}
    }

    for _, t in pairs(all_tasks) do
        table.insert(col_tasks[t.status] or col_tasks[task_status.ToDo.title], t.title)
    end

    for i, state in ipairs(states) do
        kanban.buffers[state.title] = create_buffer(state.title)
        local win = create_kanban_column(
            kanban.buffers[state.title],
            state,
            col_tasks[state.title],
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
