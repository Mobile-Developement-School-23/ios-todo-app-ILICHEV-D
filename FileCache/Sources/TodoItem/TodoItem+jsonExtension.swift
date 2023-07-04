import Foundation
import UIKit

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

    public static func parse(json: Any) -> TodoItem? {
        guard let jsonDict = json as? [String: Any],
              let id = jsonDict["id"] as? String,
              let text = jsonDict["text"] as? String,
              let isDone = jsonDict["done"] as? Bool,
              let creationDateInt = jsonDict["created_at"] as? Int64
        else {
            return nil
        }
        
        let creationDate = Date(timeIntervalSince1970: TimeInterval(integerLiteral: creationDateInt))

        let importance: Importance = {
            if let importanceString = jsonDict["importance"] as? String,
               let importance = Importance(rawValue: importanceString) {
                return importance
            }
            return .normal
        }()

        let deadline: Date? = {
            if let deadlineDateInt = jsonDict["deadline"] as? Int64 {
                return Date(timeIntervalSince1970: TimeInterval(integerLiteral: deadlineDateInt))
            }
            return nil
        }()

        let modificationDate: Date? = {
            if let modificationDateInt = jsonDict["changed_at"] as? Int64 {
                return Date(timeIntervalSince1970: TimeInterval(integerLiteral: modificationDateInt))
            }
            return nil
        }()

        let color: String? = {
            if let color = jsonDict["color"] as? String {
                return color
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
            modificationDate: modificationDate,
            color: color
        )
    }

    public var json: Any {
        var jsonDict: [String: Any] = [
            "id": id,
            "text": text,
            "done": isDone,
            "created_at": Int(creationDate.timeIntervalSince1970),
            "last_updated_by": UIDevice.current.identifierForVendor?.uuidString ?? ""
        ]
        
        jsonDict["importance"] = importance.rawValue
        
        if let deadline = deadline {
            jsonDict["deadline"] = Int(deadline.timeIntervalSince1970)
        }
        if let modificationDate = modificationDate {
            jsonDict["changed_at"] = Int(modificationDate.timeIntervalSince1970)
        } else {
            jsonDict["changed_at"] = Int(creationDate.timeIntervalSince1970)
        }
        if let color = color {
            jsonDict["color"] = color
        }
        return jsonDict
    }

}
//
//// MARK: - Welcomer
//public struct Common: Codable {
//    let revision: Int
//    let list: [TodoItem]
//    let status: String
//}
