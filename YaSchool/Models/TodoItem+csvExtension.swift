import Foundation

extension TodoItem {
    
    /**
     Function for the TodoItem structure for conversion from CSV
     
     - parameter csvString: CSV string.
     - returns: Array from TodoItem
     - warning: Assuming CSV format: id,text,importance,deadline,isDone,creationDate,modificationDate
     
     */
    static func parseCSV(csvString: String) -> [TodoItem] {
        var todoItems: [TodoItem] = []
        
        let rows = csvString.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            
            guard columns.count >= 7 else {
                continue
            }
            let id = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
            
            let text = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
            
            let importanceString = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
            let importance = Importance(rawValue: importanceString) ?? .normal
            
            let deadline: Date? = {
                let deadlineString = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
                return deadlineString.isEmpty ? nil : ISO8601DateFormatter().date(from: deadlineString)
            }()
            
            let isDoneString = columns[4].trimmingCharacters(in: .whitespacesAndNewlines)
            let creationDateString = columns[5].trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let isDone = Bool(isDoneString),
                  let creationDate = ISO8601DateFormatter().date(from: creationDateString) else {
                continue
            }
            
            let modificationDate: Date? = {
                let modificationDateString = columns[6].trimmingCharacters(in: .whitespacesAndNewlines)
                return modificationDateString.isEmpty ? nil : ISO8601DateFormatter().date(from: modificationDateString)
            }()
            
            let todoItem = TodoItem(
                id: id,
                text: text,
                importance: importance,
                deadline: deadline,
                isDone: isDone,
                creationDate: creationDate,
                modificationDate: modificationDate
            )
            
            todoItems.append(todoItem)
        }
        
        return todoItems
    }
    
    func toCSV() -> String {
        var csvString = "\(id),\(text),\(importance.rawValue),"
        
        if let deadline = deadline {
            csvString += "\(ISO8601DateFormatter().string(from: deadline)),"
        } else {
            csvString += ","
        }
        
        csvString += "\(isDone),\(ISO8601DateFormatter().string(from: creationDate)),"
        
        if let modificationDate = modificationDate {
            csvString += "\(ISO8601DateFormatter().string(from: modificationDate))"
        }
        
        return csvString
    }
    
}
