import Foundation
import TodoItem

public protocol FileCacheType {

    func add(todoItem: TodoItem)

    func removeTodoItem(withID id: String)

    func checkTodoItem(withID id: String)

    func loadTodoItems() -> [TodoItem]

}
