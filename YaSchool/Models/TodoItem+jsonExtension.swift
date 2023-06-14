import Foundation


/**
 Extension for the TodoItem structure for JSON converting
 
 - Contains a function (static func parse(json: Any) -> TodoItem?) for parsing json
 - Contains a computable property (var json: Any) for generating json
 - Do not save the importance in json if it is "обычная"
 - Do not save complex objects in json (Date)
 - Save deadline only if it is set
 - Be sure to use JSONSerialization (i.e. working with a dictionary)
 */
extension TodoItem {
    
    static func parse(json: Any) -> TodoItem? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let id = jsonDict["id"] as? String,
              let text = jsonDict["text"] as? String,
              let isDone = jsonDict["isDone"] as? Bool,
              let creationDateString = jsonDict["creationDate"] as? String,
              let creationDate = ISO8601DateFormatter().date(from: creationDateString)
        else {
            return nil
        }
        
        let importance: Importance = {
            if let importanceString = jsonDict["importance"] as? String,
               let importance = Importance(rawValue: importanceString) {
                return importance
            }
            return .normal
        }()
        
        let deadline: Date? = {
            if let deadlineString = jsonDict["deadline"] as? String {
                return ISO8601DateFormatter().date(from: deadlineString)
            }
            return nil
        }()
        
        let modificationDate: Date? = {
            if let modificationDateString = jsonDict["modificationDate"] as? String {
                return ISO8601DateFormatter().date(from: modificationDateString)
            }
            return nil
        }()
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            creationDate: creationDate,
            modificationDate: modificationDate
        )
    }
    
    var json: Any {
        var jsonDict: [String: Any] = [
            "id": id,
            "text": text,
            "isDone": isDone,
            "creationDate": ISO8601DateFormatter().string(from: creationDate)
        ]
        
        if importance != .normal {
            jsonDict["importance"] = importance.rawValue
        }
        if let deadline = deadline {
            jsonDict["deadline"] = ISO8601DateFormatter().string(from: deadline)
        }
        if let modificationDate = modificationDate {
            jsonDict["modificationDate"] = ISO8601DateFormatter().string(from: modificationDate)
        }
        return jsonDict
    }
    
}
