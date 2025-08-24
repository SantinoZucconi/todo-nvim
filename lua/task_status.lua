local TaskStatus = {
    ToDo = "ToDo",
    InProgress = "InProgress",
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
