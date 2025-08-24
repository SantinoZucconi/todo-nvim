local edit = {}
local lib = require("lib")

local close_buf_fn = function()
    lib.close_buf_if_valid(edit.current_task.title_buf)
    lib.close_buf_if_valid(edit.current_task.desc_buf)
end

local close_win_fn = function()
    lib.close_win_if_valid(edit.current_task.title_win)
    lib.close_win_if_valid(edit.current_task.desc_win)
end

local toggle_win = function ()
    if edit.current_task.current_win == edit.current_task.title_win then
        vim.api.nvim_set_current_win(edit.current_task.desc_win)
        edit.current_task.current_win = edit.current_task.desc_win
    else
        vim.api.nvim_set_current_win(edit.current_task.title_win)
        edit.current_task.current_win = edit.current_task.title_win
    end
end

local function save_edited_task()
    local title_lines = vim.api.nvim_buf_get_lines(edit.current_task.title_buf, 0, -1, false)
    local desc_lines = vim.api.nvim_buf_get_lines(edit.current_task.desc_buf, 0, -1, false)
    local title = table.concat(title_lines, " ")
    local desc = table.concat(desc_lines, "\n")
    edit.tasks[edit.current_task.id].title = title
    edit.tasks[edit.current_task.id].description = desc
    lib.rewrite_file(edit.tasks)
    close_win_fn()
    close_buf_fn()
    edit.current_task = nil
end

function edit.edit_task(task_id)
    local tasks = lib.open_task_file()
    local task = tasks[task_id]
    local title_buf, desc_buf = lib.create_task_buffer()
    edit.tasks = tasks
    edit.current_task = {
        title_buf = title_buf,
        desc_buf = desc_buf,
        id = task_id
    }
    edit.current_task.title_win = lib.create_title_window(edit.current_task.title_buf)
    edit.current_task.desc_win = lib.create_desc_window(edit.current_task.desc_buf)

    local desc_lines = vim.split(task.description, "\n");

    vim.api.nvim_buf_set_lines(edit.current_task.title_buf, 0, -1, false, {task.title})
    vim.api.nvim_buf_set_lines(edit.current_task.desc_buf, 0, -1, false, desc_lines)

    vim.api.nvim_set_current_win(edit.current_task.title_win)
    edit.current_task.current_win = edit.current_task.title_win

    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = edit.current_task.title_buf,
        callback = save_edited_task
    })
    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = edit.current_task.desc_buf,
        callback = save_edited_task
    })

    vim.keymap.set("n", "q", save_edited_task, { buffer = edit.current_task.title_buf })
    vim.keymap.set("n", "q", save_edited_task, { buffer = edit.current_task.desc_buf })
    vim.keymap.set("n", "<Cr>", toggle_win, { buffer = edit.current_task.title_buf })
    vim.keymap.set("i", "<Cr>", toggle_win, { buffer = edit.current_task.title_buf })
    vim.keymap.set("n", "<Cr>", toggle_win, { buffer = edit.current_task.desc_buf })
end

return edit
