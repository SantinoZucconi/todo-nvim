local lib = require("lib")
local create = {}

create.current_task = nil

local close_buf_fn = function()
    lib.close_buf_if_valid(create.current_task.title_buf)
    lib.close_buf_if_valid(create.current_task.desc_buf)
end

local close_win_fn = function()
    lib.close_win_if_valid(create.current_task.title_win)
    lib.close_win_if_valid(create.current_task.desc_win)
end

local toggle_win = function ()
    if create.current_task.current_win == create.current_task.title_win then
        vim.api.nvim_set_current_win(create.current_task.desc_win)
        create.current_task.current_win = create.current_task.desc_win
    else
        vim.api.nvim_set_current_win(create.current_task.title_win)
        create.current_task.current_win = create.current_task.title_win
    end
end

function create.add_task()
    if create.current_task then
        close_win_fn()
    else
        local title_buf, desc_buf = lib.create_task_buffer()
        create.current_task = {
            title_buf = title_buf,
            desc_buf = desc_buf
        }
    end
    create.current_task.title_win = lib.create_title_window(create.current_task.title_buf)
    create.current_task.desc_win = lib.create_desc_window(create.current_task.desc_buf)

    vim.api.nvim_set_current_win(create.current_task.title_win)
    create.current_task.current_win = create.current_task.title_win

    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = create.current_task.title_buf,
        callback = function()
            lib.save_task(create.current_task.title_buf, create.current_task.desc_buf)
            close_win_fn()
            close_buf_fn()
            create.current_task = nil
        end
    })
    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = create.current_task.desc_buf,
        callback = function()
            lib.save_task(create.current_task.title_buf, create.current_task.desc_buf)
            close_win_fn()
            close_buf_fn()
            create.current_task = nil
        end
    })

    vim.keymap.set("n", "q", close_win_fn, { buffer = create.current_task.title_buf })
    vim.keymap.set("n", "q", close_win_fn, { buffer = create.current_task.desc_buf })
    vim.keymap.set("n", "<Cr>", toggle_win, { buffer = create.current_task.title_buf })
    vim.keymap.set("i", "<Cr>", toggle_win, { buffer = create.current_task.title_buf })
    vim.keymap.set("n", "<Cr>", toggle_win, { buffer = create.current_task.desc_buf })
end

return create
