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


final class FileCache: FileCacheType {
    
    private(set) var todoItems: [TodoItem]
    private let filename: String
    private let fileType: FileType
    
    init(filename: String, fileType: FileType) {
        self.filename = filename
        self.todoItems = []
        self.fileType = fileType
        loadFromFile()
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
        switch fileType {
        case .json:
            saveJSONToFile()
        case .csv:
            saveCSVToFile()
        }
    }
    
    private func loadFromFile() {
        switch fileType {
        case .json:
            loadJSONFromFile()
        case .csv:
            loadCSVFromFile()
        }
    }
    
    // MARK: - JSON Handling
    
    private func saveJSONToFile() {
        guard let url = fileURL() else { return }
        
        let json = todoItems.map { $0.json }
        do {
            let data = try JSONSerialization.data(withJSONObject: json)
            try data.write(to: url)
        } catch {
            print("Failed to save data: \(error)")
        }
    }
    
    private func loadJSONFromFile() {
        guard let url = fileURL() else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data)
            if let jsonArray = json as? [Any] {
                todoItems = jsonArray.compactMap { TodoItem.parse(json: $0) }
            } else {
                return
            }
        } catch {
            saveJSONToFile()
        }
    }
    
    // MARK: - CSV Handling
    
    private func saveCSVToFile() {
        guard let url = fileURL() else { return }
        
        let csvString = todoItems.map { $0.toCSV() }.joined(separator: "\n")
        do {
            try csvString.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to save data: \(error)")
        }
    }
    
    private func loadCSVFromFile() {
        guard let url = fileURL() else { return }
        
        do {
            let csvString = try String(contentsOf: url, encoding: .utf8)
            todoItems = TodoItem.parseCSV(csvString: csvString)
        } catch {
            saveCSVToFile()
        }
    }
    
    private func fileURL() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename)
    }
    
}

// MARK: Helpers

enum FileType {
    case json
    case csv
}
