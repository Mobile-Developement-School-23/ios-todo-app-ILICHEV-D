import Foundation

class TaskDetailsInteractor: TaskDetailsInteractorInput {
    
    let fileCashe: FileCacheType
    
    init(fileCashe: FileCacheType) {
        self.fileCashe = fileCashe
    }
    
}

// MARK: Private

extension TaskDetailsInteractor {
    
    func obtainRandomTask() -> TodoItem? {
        fileCashe.todoItems.last
    }
    
    func deleteTask(todoItem: TodoItem) {
        fileCashe.removeTodoItem(withID: todoItem.id)
    }
    
    func saveTask(todoItem: TodoItem) {
        fileCashe.addTodoItem(todoItem)
    }
    
}
