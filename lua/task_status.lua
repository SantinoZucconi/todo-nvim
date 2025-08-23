local TaskStatus = {
    ToDo = "To Do",
    InProgress = "In Progress",
    Done = "Done",
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
