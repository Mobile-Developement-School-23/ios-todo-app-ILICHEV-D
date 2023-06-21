import Foundation

protocol FileCacheType {
	
    var todoItems: [TodoItem] { get }
    
    func addTodoItem(_ todoItem: TodoItem)
    
    func removeTodoItem(withID id: String)
    
}
