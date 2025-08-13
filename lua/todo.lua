local M = {}

M.setup = function()
    vim.keymap.set("n", "<leader>tt", function()
        M.add_task()
    end, { desc = "Test keymap mi_plugin" })
end

M.current_task = nil

local create_title_window = function(win_config, buf)
    local title_win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = win_config.width,
        height = math.floor(win_config.height * 0.1),
        row = win_config.row,
        col = win_config.col,
        style = "minimal",
        border = "rounded",
        title = " Título ",
        title_pos = "left"
    })
    return title_win
end

local create_desc_window = function(win_config, buf)
    local desc_win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = win_config.width,
        height = math.floor(win_config.height * 0.5),
        row = win_config.row + math.floor(win_config.height * 0.2),
        col = win_config.col,
        style = "minimal",
        border = "rounded",
        title = " Descripción ",
        title_pos = "left"
    })
    return desc_win
end

local close_buf_fn = function()
    if vim.api.nvim_buf_is_valid(M.current_task.title_buf) then
        vim.api.nvim_buf_delete(M.current_task.title_buf, {force = true})
    end
    if vim.api.nvim_buf_is_valid(M.current_task.desc_buf) then
        vim.api.nvim_buf_delete(M.current_task.desc_buf, {force = true})
    end
end

local close_win_fn = function()
    if vim.api.nvim_win_is_valid(M.current_task.title_win) then
        vim.api.nvim_win_close(M.current_task.title_win, true)
    end
    if vim.api.nvim_win_is_valid(M.current_task.desc_win) then
        vim.api.nvim_win_close(M.current_task.desc_win, true)
    end
end

local function save_task()
    local title_lines = vim.api.nvim_buf_get_lines(M.current_task.title_buf, 0, -1, false)
    local desc_lines = vim.api.nvim_buf_get_lines(M.current_task.desc_buf, 0, -1, false)

    local title = table.concat(title_lines, " ")
    local desc = table.concat(desc_lines, " ")

    if title == "" and desc == "" then
        print("No se puede guardar: título y descripción vacíos")
        return
    end

    local task = {
        title = title,
        description = desc,
        created_at = os.date("%Y-%m-%d %H:%M:%S"),
    }

    local file = io.open(".tasks.jsonl", "a")
    if file then
        file:write(vim.fn.json_encode(task) .. "\n")
        file:close()
    else
        print("Error al abrir .tasks.jsonl")
    end
    close_win_fn()
    close_buf_fn()
    M.current_task = nil
end

local toggle_win = function ()
    if M.current_task.current_win == M.current_task.title_win then
        vim.api.nvim_set_current_win(M.current_task.desc_win)
        M.current_task.current_win = M.current_task.desc_win
    else
        vim.api.nvim_set_current_win(M.current_task.title_win)
        M.current_task.current_win = M.current_task.title_win
    end
end

M.add_task = function()
    local width = math.floor(vim.o.columns * 0.5)
    local height = math.floor(vim.o.lines * 0.6)
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    local win_config = {
        width = width,
        height = height,
        row = row,
        col = col
    }
    if M.current_task then
        if vim.api.nvim_win_is_valid(M.current_task.title_win) then
            vim.api.nvim_win_close(M.current_task.title_win, true)
        end
        if vim.api.nvim_win_is_valid(M.current_task.desc_win) then
            vim.api.nvim_win_close(M.current_task.desc_win, true)
        end
    else
        local title_buf = vim.api.nvim_create_buf(false, false)
        local desc_buf = vim.api.nvim_create_buf(false, false)
        vim.api.nvim_buf_set_name(title_buf, vim.fn.tempname() .. "-title")
        vim.api.nvim_buf_set_name(desc_buf, vim.fn.tempname() .. "-desc")
        vim.api.nvim_set_option_value("swapfile", false, { buf = title_buf })
        vim.api.nvim_set_option_value("swapfile", false, { buf = desc_buf })
        M.current_task = {
            title_buf = title_buf,
            desc_buf = desc_buf
        }
    end

    M.current_task.title_win = create_title_window(win_config, M.current_task.title_buf)
    M.current_task.desc_win = create_desc_window(win_config, M.current_task.desc_buf)

    vim.api.nvim_set_current_win(M.current_task.title_win)
    M.current_task.current_win = M.current_task.title_win


    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = M.current_task.title_buf,
        callback = function()
            save_task(M.current_task.title_buf)
        end
    })
    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = M.current_task.desc_buf,
        callback = function()
            save_task(M.current_task.desc_buf)
        end
    })

    vim.keymap.set("n", "q", close_win_fn, { buffer = M.current_task.title_buf })
    vim.keymap.set("n", "q", close_win_fn, { buffer = M.current_task.desc_buf })

    vim.keymap.set("n", "<Cr>", toggle_win, { buffer = M.current_task.title_buf })
    vim.keymap.set("i", "<Cr>", toggle_win, { buffer = M.current_task.title_buf })
    vim.keymap.set("n", "<Cr>", toggle_win, { buffer = M.current_task.desc_buf })
end

M.view_tasks = function()
end

return M
