import Foundation
import TodoItem

public protocol FileCacheType {

    func add(todoItem: TodoItem)

    func removeTodoItem(withID id: String)

    func checkTodoItem(withID id: String) -> TodoItem?

    func loadTodoItems() -> [TodoItem]
    
    func setItems(_ items: [TodoItem])

    func setDirty(_ isDirty: Bool)
    
    func getIsDirty() -> Bool
}
