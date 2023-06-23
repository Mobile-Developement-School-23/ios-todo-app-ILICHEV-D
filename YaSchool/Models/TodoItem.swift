import Foundation

/**
 Describes the task in TodoList
 
 - Immunable structure.
 - Contains a unique identifier id, if not specified by the user - generated (UUID().UUIDString).
 - Contains a mandatory string field - text.
 - Contains a mandatory importance field, must be enum, can have three options - "неважная", "обычная" and "важная".
 - Contains a deadline, may not be set if a date is set.
 - Contains a flag that the task is done.
 - Contains two dates - the date of creation of the task (required) and the date of change (optional).
 */
struct TodoItem {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let creationDate: Date
    let modificationDate: Date?
    var color: String?
    
    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance,
        deadline: Date?,
        isDone: Bool,
        creationDate: Date,
        modificationDate: Date? = nil,
        color: String? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.color = color
    }
}

enum Importance: String {
    case low = "неважная"
    case normal = "обычная"
    case high = "важная"
}

