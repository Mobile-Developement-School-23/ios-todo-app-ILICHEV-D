import Foundation
import FileCache
import TodoItem

class TodoListInteractor {

    let fileCashe: FileCacheType
    let networkService: NetworkingServiceProtocol

    init(fileCashe: FileCacheType, networkService: NetworkingServiceProtocol) {
        self.fileCashe = fileCashe
        self.networkService = networkService
    }

}

extension TodoListInteractor: TodoListInteractorInput {
    
    func saveTaskLocally(item: TodoItem) -> [TodoItem] {
        fileCashe.add(todoItem: item)
        return fileCashe.loadTodoItems()
    }
    
    func obtainTasksLocally() -> [TodoItem] {
        fileCashe.loadTodoItems()
    }

    func deleteTaskLocally(id: String) -> [TodoItem] {
        fileCashe.removeTodoItem(withID: id)
        return fileCashe.loadTodoItems()
    }

    func checkTaskLocally(id: String) -> [TodoItem] {
        let _ = fileCashe.checkTodoItem(withID: id)
        return fileCashe.loadTodoItems()
    }
    
    func obtainTasks() async throws -> [TodoItem] {
        try await networkService.getList()
    }

    func deleteTask(id: String) async throws {
        let _ = try await networkService.deleteTodoItem(withId: id)
    }

    func checkTask(id: String) async throws {
        if let todoItem = fileCashe.loadTodoItems().first(where: { $0.id == id }) {
           let _ = try await networkService.updateTodoItem(withId: todoItem.id, item: todoItem)
        }
    }
    
    func setLocalItems(_ items: [TodoItem]) {
        fileCashe.setItems(items)
    }
    
    func saveTask(item: TodoItem) async throws {
        let _ = try await networkService.createTodoItem(item)
    }
    
    func updateTask(item: TodoItem) async throws {
        let _ = try await networkService.updateTodoItem(withId: item.id, item: item)
    }
    
    func setItemsDirty(_ isDirty: Bool) {
        fileCashe.setDirty(isDirty)
    }
    
    func isListDirty() -> Bool {
        fileCashe.getIsDirty()
    }
    
    func updateItems() async throws -> [TodoItem] {
        try await networkService.updateList(with: fileCashe.loadTodoItems())
    }

}
