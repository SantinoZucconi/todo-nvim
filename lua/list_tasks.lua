local list = {}
local has_telescope, pickers = pcall(require, "telescope.pickers")
local lib = require("lib")
if not has_telescope then
  return
end

local finders = require("telescope.finders")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function make_separator(label, width)
    local total = width - #label
    local first_half = math.floor(total / 2) - 3
    local second_half = math.ceil(total / 2) - 3
    return string.rep("─", first_half) .. " **" .. label .. "** " .. string.rep("─", second_half)
end

function list.list_tasks()
  local tasks = lib.open_task_file()

  pickers.new({}, {
      prompt_title = "Tasks",
      layout_strategy = "horizontal",
      layout_config = {
          width = 0.6,
          height = 0.8,
          preview_width = 0.7,
          -- prompt_position = "top", -- opcional
      },
      finder = finders.new_table {
          results = tasks,
          entry_maker = function(entry)
              return {
                  value = entry,
                  display = entry.title,
                  status = entry.status,
                  ordinal = entry.title,
              }
          end,
      },
      sorter = conf.generic_sorter({}),
      previewer = previewers.new_buffer_previewer {
          define_preview = function(self, entry, status)
              local winid = self.state.winid
              local win_width = vim.api.nvim_win_get_width(winid)
              local lines = {
                  make_separator("Title", win_width),
                  " ",
                  entry.display,
                  " ",
                  make_separator("Status", win_width),
                  " ",
                  entry.status,
                  " ",
                  make_separator("Description", win_width),
                  " ",
              }
              if entry.value.description then
                  vim.list_extend(lines, vim.split(entry.value.description, "\n"))
              end
              vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
              vim.api.nvim_set_option_value("filetype", "markdown", { buf = self.state.bufnr })
              vim.api.nvim_set_option_value("wrap", true, { win = self.state.winid })
              vim.api.nvim_set_option_value("linebreak", true, { win = self.state.winid })
              vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { fg = "#ffffff", bg = nil })
          end
      },
      attach_mappings = function(prompt_bufnr, map)
          local close_picker = function()
              actions.close(prompt_bufnr)
          end

          local get_selection = function()
              return action_state.get_selected_entry()
          end

          actions.select_default:replace(function()
              local selection = get_selection()
              print("Ver task: " .. selection.value.title)
              close_picker()
          end)

          map("n", "a", function()
              local selection = get_selection()
              close_picker()
              print("Editar task: " .. selection.value.title)
          end)

          map("n", "d", function()
              local selection = get_selection()
              close_picker()
              print("Borrar task: " .. selection.value.title)
          end)

          map("n", "s", function()
              local selection = get_selection()
              close_picker()
              print("Cambiar estado de: " .. selection.value.title)
          end)
          return true
      end,
      initial_mode = "normal",
  }):find()
end

return list
