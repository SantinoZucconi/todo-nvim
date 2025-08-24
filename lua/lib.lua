local config = require("config")
local task_status = require("task_status")
local lib = {}

function lib.create_title_window(buf)
    local win_config = config.win_config()
    local title_win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = win_config.width,
        height = math.floor(win_config.height * 0.1),
        row = win_config.row,
        col = win_config.col,
        style = "minimal",
        border = "rounded",
        title = " Title ",
        title_pos = "left"
    })
    return title_win
end

function lib.create_desc_window(buf)
    local win_config = config.win_config()
    local desc_win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = win_config.width,
        height = math.floor(win_config.height * 0.5),
        row = win_config.row + math.floor(win_config.height * 0.2),
        col = win_config.col,
        style = "minimal",
        border = "rounded",
        title = " Description ",
        title_pos = "left"
    })
    return desc_win
end

function lib.create_task_buffer()
    local title_buf = vim.api.nvim_create_buf(false, false)
    local desc_buf = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_buf_set_name(title_buf, vim.fn.tempname() .. "-title")
    vim.api.nvim_buf_set_name(desc_buf, vim.fn.tempname() .. "-desc")
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = desc_buf })
    vim.api.nvim_set_option_value("swapfile", false, { buf = title_buf })
    vim.api.nvim_set_option_value("swapfile", false, { buf = desc_buf })
    return title_buf, desc_buf
end

function lib.close_buf_if_valid(bufnr)
    if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, {force = true})
    end
end

function lib.close_win_if_valid(winnr)
    if vim.api.nvim_win_is_valid(winnr) then
        vim.api.nvim_win_close(winnr, true)
    end
end

function lib.save_task(title_buf, desc_buf)
    local title_lines = vim.api.nvim_buf_get_lines(title_buf, 0, -1, false)
    local desc_lines = vim.api.nvim_buf_get_lines(desc_buf, 0, -1, false)
    local title = table.concat(title_lines, " ")
    local desc = table.concat(desc_lines, "\n")

    if title == "" and desc == "" then
        print("No se puede guardar: título y descripción vacíos")
        return
    end

    local id = vim.fn.sha256(vim.fn.reltimefloat(vim.fn.reltime()))
    local task = {
        id = id,
        title = title,
        description = desc,
        status = task_status.ToDo.title,
        created_at = os.date("%Y-%m-%d %H:%M:%S"),
    }

    local file = io.open(".tasks.jsonl", "a")
    if file then
        file:write(vim.fn.json_encode(task) .. "\n")
        file:close()
    else
        print("Error al abrir .tasks.jsonl")
    end
end

function lib.rewrite_file(tasks)
    local file = io.open(".tasks.jsonl", "w")
    if file then
        for _, task in pairs(tasks) do
            file:write(vim.fn.json_encode(task) .. "\n")
        end
        file:close()
    else
        print("Error al abrir .tasks.jsonl")
    end
end

function lib.open_task_file()
    local tasks = {}
    local file = io.open(".tasks.jsonl", "r")
    if file then
        for line in file:lines() do
            local ok, decoded = pcall(vim.fn.json_decode, line)
            if ok and decoded then
                tasks[decoded.id] = decoded
            end
        end
        file:close()
    end
    return tasks
end

return lib
