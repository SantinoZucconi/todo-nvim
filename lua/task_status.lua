local TaskStatus = {
    Pending = "pending",
    InProgress = "in_progress",
    Done = "done",
}

local TaskTransitions = {
    [TaskStatus.Pending] = TaskStatus.InProgress,
    [TaskStatus.InProgress] = TaskStatus.Done,
    [TaskStatus.Done] = nil,
}

function TaskStatus.next(current)
    return TaskTransitions[current]
end

return TaskStatus
