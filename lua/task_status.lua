local TaskStatus = {
    ToDo = {
        title = "To Do",
        nameid = "kanban_to_do"
    },
    InProgress = {
        title = "In Progress",
        nameid = "kanban_in_progress"
    },
    Done = {
        title = "Done",
        nameid = "kanban_done"
    },
}

local TaskTransitions = {
    [TaskStatus.ToDo] = TaskStatus.InProgress,
    [TaskStatus.InProgress] = TaskStatus.Done,
    [TaskStatus.Done] = nil,
}

function TaskStatus.next(current)
    return TaskTransitions[current]
end

return TaskStatus
