//〉Содержит закрытую для внешнего изменения, но открытую для получения коллекцию TodoItem
//〉Содержит функцию добавления новой задачи
//〉Содержит функцию удаления задачи (на основе id)
//〉Содержит функцию сохранения всех дел в файл
//〉Содержит функцию загрузки всех дел из файла
//〉Можем иметь несколько разных файлов
//〉Предусмотреть механизм защиты от дублирования задач (сравниванием id)

import Foundation

/**
 A class for working with TodoItems

 - Contains a TodoItem collection closed for external modification, but open for receiving
 - Contains a function for adding a new task
 - Contains the task deletion function (based on id)
 - Contains the function of saving all cases to a file
 - Contains the function of downloading all cases from a file
 - We can have several different files
 - Provide a mechanism to protect against duplication of tasks (by comparing IDs)
 */
class FileCache {
    
    private var todoItems: [TodoItem]
    private let filename: String
    
    init(filename: String) {
        self.filename = filename
        self.todoItems = []
        loadFromFile()
    }
    
    var allTodoItems: [TodoItem] {
        return todoItems
    }
    
    func addTodoItem(_ todoItem: TodoItem) {
        if let index = todoItems.firstIndex(where: { $0.id == todoItem.id }) {
            todoItems[index] = todoItem
        } else {
            todoItems.append(todoItem)
        }
        saveToFile()
    }
    
    func removeTodoItem(withID id: String) {
        todoItems.removeAll { $0.id == id }
        saveToFile()
    }
    
    private func saveToFile() {
        let json = todoItems.map { $0.json }
        if let url = fileURL() {
            do {
                let data = try JSONSerialization.data(withJSONObject: json)
                try data.write(to: url)
            } catch {
                print("Failed to save data: \(error)")
            }
        }
    }
    
    private func loadFromFile() {
        if let url = fileURL() {
            do {
                let data = try Data(contentsOf: url)
                let json = try JSONSerialization.jsonObject(with: data)
                if let jsonArray = json as? [Any] {
                    todoItems = jsonArray.compactMap { TodoItem.parse(json: $0) }
                } else {
                    return
                }
            } catch {
                saveToFile()
            }
        }
    }
    
    private func fileURL() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename)
    }
    
}
