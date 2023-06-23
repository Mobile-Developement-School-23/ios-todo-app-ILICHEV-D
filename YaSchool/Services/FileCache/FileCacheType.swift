import Foundation

protocol FileCacheType {
	
    var todoItems: [TodoItem] { get }
    
    func add(todoItem: TodoItem)
    
    func removeTodoItem(withID id: String)
    
}
