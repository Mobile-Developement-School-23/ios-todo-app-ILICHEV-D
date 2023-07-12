import Foundation
import TodoItem

public final class FileCache: FileCacheType {

    var todoItems: [TodoItem]
    private let filename: String
    private let fileType: FileType
    
    private var isDirty = false
    
    var db: OpaquePointer?

    public init(filename: String, fileType: FileType) {
        self.filename = filename
        self.todoItems = []
        self.fileType = fileType
        self.db = openDatabase(filename: filename)
        _ = loadFromFile()
    }

    public func add(todoItem: TodoItem) {
        var shouldUpdate = false
        var updateIndex = 0
        if let index = todoItems.firstIndex(where: { $0.id == todoItem.id }) {
            todoItems[index] = todoItem
            updateIndex = index
            shouldUpdate = true
        } else {
            todoItems.append(todoItem)
        }
        
        switch fileType {
        case .json, .csv:
            saveToFile()
        case .sqlite:
            shouldUpdate ? update(todoItems[updateIndex]) : insert(todoItem)
        }
    }

    public func removeTodoItem(withID id: String) {
        let item = todoItems.first { $0.id == id }
        todoItems.removeAll { $0.id == id }
        switch fileType {
        case .json, .csv:
            saveToFile()
        case .sqlite:
            if let item = item {
                delete(item)
            } else {
                saveToFile()
            }
        }
    }

    public func checkTodoItem(withID id: String) -> TodoItem? {
        var item = todoItems.first { $0.id == id }
        item?.isDone.toggle()
        if let item = item {
            add(todoItem: item)
            return item
        }
        return nil
    }

    public func loadTodoItems() -> [TodoItem] {
        loadFromFile() ?? []
    }
    
    public func setItems(_ items: [TodoItem]) {
        todoItems = items
        saveToFile()
    }

    public func setDirty(_ isDirty: Bool) {
        self.isDirty = isDirty
    }
    
    public func getIsDirty() -> Bool {
        self.isDirty
    }
        
    private func saveToFile() {
        switch fileType {
        case .json:
            saveJSONToFile()
        case .csv:
            saveCSVToFile()
        case .sqlite:
            save()
        }
    }

    private func loadFromFile() -> [TodoItem]? {
        switch fileType {
        case .json:
            return loadJSONFromFile()
        case .csv:
            return loadCSVFromFile()
        case .sqlite:
            return load()
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

    private func loadJSONFromFile() -> [TodoItem]? {
        guard let url = fileURL() else { return nil }

        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data)
            if let jsonArray = json as? [Any] {
                todoItems = jsonArray.compactMap { TodoItem.parse(json: $0) }
                return todoItems
            } else {
                return []
            }
        } catch {
            saveJSONToFile()
        }
        return []
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

    private func loadCSVFromFile() -> [TodoItem]? {
        guard let url = fileURL() else { return [] }

        do {
            let csvString = try String(contentsOf: url, encoding: .utf8)
            todoItems = TodoItem.parseCSV(csvString: csvString)
            return todoItems
        } catch {
            saveCSVToFile()
        }
        return []
    }

    func fileURL() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename)
    }

}

// MARK: Helpers

public enum FileType {
    case json
    case csv
    case sqlite
}
