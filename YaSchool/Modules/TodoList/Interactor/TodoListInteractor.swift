import Foundation

class TodoListInteractor {

    let fileCashe: FileCacheType

    init(fileCashe: FileCacheType) {
        self.fileCashe = fileCashe
    }

}

extension TodoListInteractor: TodoListInteractorInput {

    func obtainTasks() -> [TodoItem] {
        fileCashe.loadTodoItems()
    }

    func deleteTask(id: String) -> [TodoItem] {
        fileCashe.removeTodoItem(withID: id)
        return fileCashe.loadTodoItems()
    }

    func checkTask(id: String) -> [TodoItem] {
        fileCashe.checkTodoItem(withID: id)
        return fileCashe.loadTodoItems()
    }

    func saveTask(todoItem: TodoItem) {
        fileCashe.add(todoItem: todoItem)
    }

}
