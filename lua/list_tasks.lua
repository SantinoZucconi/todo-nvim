local list = {}
local has_telescope, pickers = pcall(require, "telescope.pickers")
if not has_telescope then
  return
end

local finders = require("telescope.finders")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function open_task_file()
    local tasks = {}
    local file = io.open(".tasks.jsonl", "r")
    if file then
        for line in file:lines() do
            local ok, decoded = pcall(vim.fn.json_decode, line)
            if ok and decoded then
                table.insert(tasks, decoded)
            end
        end
        file:close()
    end
    return tasks
end

function list.list_tasks()
  local tasks = open_task_file()

  pickers.new({}, {
      prompt_title = "Tasks",
      finder = finders.new_table {
          results = tasks,
          entry_maker = function(entry)
              return {
                  value = entry,
                  display = entry.title,
                  ordinal = entry.title,
              }
          end,
      },
      sorter = conf.generic_sorter({}),
      previewer = previewers.new_buffer_previewer {
          define_preview = function(self, entry, status)
              local lines = vim.split(entry.value.description, "\n")
              vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
              vim.api.nvim_set_option_value("filetype", "markdown", { buf = self.state.bufnr })
              vim.api.nvim_set_option_value("wrap", true, { win = self.state.winid })
              vim.api.nvim_set_option_value("linebreak", true, { win = self.state.winid })
          end
      },
      attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              print("Seleccionaste task: " .. selection.value.title)
          end)
          return true
      end,
      initial_mode = "normal",
  }):find()
end

return list
