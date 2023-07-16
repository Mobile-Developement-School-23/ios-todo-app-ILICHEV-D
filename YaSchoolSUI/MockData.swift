import Foundation
import TodoItem


struct MockData {
    
    public static let items = [
        TodoItem(
            text: "Some very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very lone text y very very very very very very very very very very very very very very very very very very very very very very very very very very very very very lone text y very very very very very very very very very very very very very very very very very very very very very very very very very very very very very lone text",
            importance: .low,
            deadline: Date.tomorrow,
            isDone: false,
            creationDate: Date()
        ),
        TodoItem(
            text: "Second",
            importance: .normal,
            deadline: nil,
            isDone: false,
            creationDate: Date()
        ),
        TodoItem(
            text: "Third",
            importance: .high,
            deadline: nil,
            isDone: false,
            creationDate: Date()
        ),
        TodoItem(
            text: "Some very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very lone text",
            importance: .normal,
            deadline: nil,
            isDone: true,
            creationDate: Date()
        ),
        TodoItem(
            text: "Task with deadline",
            importance: .normal,
            deadline: Date.tomorrow,
            isDone: false,
            creationDate: Date()
        ),
        TodoItem(
            text: "",
            importance: .normal,
            deadline: nil,
            isDone: false,
            creationDate: Date()
        )
    ]
    
    
}

private extension Date {
    
    static var tomorrow: Date {
        let calendar = Calendar.current
        let today = Date()
        let midnight = calendar.startOfDay(for: today)
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: midnight) {
            return tomorrow
        }
        return today
    }
    
}
