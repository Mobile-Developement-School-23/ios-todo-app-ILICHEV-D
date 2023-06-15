import XCTest
@testable import YaSchool

final class TodoItemTests: XCTestCase {
    
    func testTodoItemInitialization() {
        let id = "1"
        let text = "text"
        let importance = Importance.high
        let deadline = Date()
        let isDone = false
        let creationDate = Date()
        let modificationDate = Date()
        
        let todoItem = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            creationDate: creationDate,
            modificationDate: modificationDate
        )
        
        XCTAssertEqual(todoItem.id, id)
        XCTAssertEqual(todoItem.text, text)
        XCTAssertEqual(todoItem.importance, importance)
        XCTAssertEqual(todoItem.deadline, deadline)
        XCTAssertEqual(todoItem.isDone, isDone)
        XCTAssertEqual(todoItem.creationDate, creationDate)
        XCTAssertEqual(todoItem.modificationDate, modificationDate)
    }
    
    func testTodoItemParsingFromJSON() {
        let json: [String: Any] = [
            "id": "1",
            "text": "text",
            "importance": "важная",
            "deadline": "2023-08-10T12:00:00Z",
            "isDone": false,
            "creationDate": "2023-06-10T12:00:00Z",
            "modificationDate": "2023-07-10T12:00:00Z"
        ]
        
        guard let todoItem = TodoItem.parse(json: json) else {
            XCTFail("Fail of parsing TodoItem")
            return
        }
        
        XCTAssertEqual(todoItem.id, "1")
        XCTAssertEqual(todoItem.text, "text")
        XCTAssertEqual(todoItem.importance, Importance.high)
        XCTAssertEqual(todoItem.deadline, ISO8601DateFormatter().date(from: "2023-08-10T12:00:00Z"))
        XCTAssertEqual(todoItem.isDone, false)
        XCTAssertEqual(todoItem.creationDate, ISO8601DateFormatter().date(from: "2023-06-10T12:00:00Z"))
        XCTAssertEqual(todoItem.modificationDate, ISO8601DateFormatter().date(from: "2023-07-10T12:00:00Z"))
    }
    
    func testTodoItemParsingFromJSONWithoutImportanceAndOptionalValues() {
        let json: [String: Any] = [
            "id": "1",
            "text": "text",
            "isDone": false,
            "creationDate": "2023-06-10T12:00:00Z",
        ]
        
        guard let todoItem = TodoItem.parse(json: json) else {
            XCTFail("Fail of parsing TodoItem")
            return
        }
        
        XCTAssertEqual(todoItem.id, "1")
        XCTAssertEqual(todoItem.text, "text")
        XCTAssertEqual(todoItem.importance, Importance.normal)
        XCTAssertEqual(todoItem.isDone, false)
        XCTAssertEqual(todoItem.creationDate, ISO8601DateFormatter().date(from: "2023-06-10T12:00:00Z"))
    }
    
    func testTodoItemSerializationToJSON() {
        guard let creationDate = ISO8601DateFormatter().date(from: "2023-06-10T12:00:00Z") else {
            XCTFail("Fail of creation of date")
            return
        }
        
        let id = "1"
        let text = "text"
        let importance = Importance.normal
        let deadline = ISO8601DateFormatter().date(from: "2023-08-10T12:00:00Z")
        let isDone = false
        let modificationDate = ISO8601DateFormatter().date(from: "2023-07-10T12:00:00Z")
        
        let todoItem = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            creationDate: creationDate,
            modificationDate: modificationDate
        )
        
        guard let json = todoItem.json as? [String: Any] else {
            XCTFail("Fail of serialization TodoItem")
            return
        }
        
        XCTAssertEqual(json["id"] as? String, "1")
        XCTAssertEqual(json["text"] as? String, "text")
        XCTAssertEqual(json["deadline"] as? String, "2023-08-10T12:00:00Z")
        XCTAssertEqual(json["isDone"] as? Bool, false)
        XCTAssertEqual(json["creationDate"] as? String, "2023-06-10T12:00:00Z")
        XCTAssertEqual(json["modificationDate"] as? String, "2023-07-10T12:00:00Z")
    }
    
    func testTodoItemCSVParsing() {
        let csvString = """
        1,First,,,false,2023-06-10T12:00:00Z,
        2,Second,важная,2023-08-10T12:00:00Z,true,2023-06-10T12:00:00Z,2023-07-10T12:00:00Z
        """
        
        let todoItems = TodoItem.parseCSV(csvString: csvString)
        
        XCTAssertEqual(todoItems.count, 2)
        
        let todoItemFirst = todoItems[0]
        XCTAssertEqual(todoItemFirst.id, "1")
        XCTAssertEqual(todoItemFirst.text, "First")
        XCTAssertEqual(todoItemFirst.importance, Importance.normal)
        XCTAssertNil(todoItemFirst.deadline)
        XCTAssertEqual(todoItemFirst.isDone, false)
        XCTAssertEqual(todoItemFirst.creationDate, ISO8601DateFormatter().date(from: "2023-06-10T12:00:00Z"))
        XCTAssertNil(todoItemFirst.modificationDate)
        
        let todoItemSecond = todoItems[1]
        XCTAssertEqual(todoItemSecond.id, "2")
        XCTAssertEqual(todoItemSecond.text, "Second")
        XCTAssertEqual(todoItemSecond.importance, Importance.high)
        XCTAssertEqual(todoItemSecond.deadline, ISO8601DateFormatter().date(from: "2023-08-10T12:00:00Z"))
        XCTAssertEqual(todoItemSecond.isDone, true)
        XCTAssertEqual(todoItemSecond.creationDate, ISO8601DateFormatter().date(from: "2023-06-10T12:00:00Z"))
        XCTAssertEqual(todoItemSecond.modificationDate, ISO8601DateFormatter().date(from: "2023-07-10T12:00:00Z"))
    }
    
    func testTodoItemCSVProcessing() {
        guard let creationDate = ISO8601DateFormatter().date(from: "2023-06-10T12:00:00Z") else {
            XCTFail("Fail of creation of date")
            return
        }
        
        let todoItemFirst = TodoItem(
            id: "1",
            text: "First",
            importance: .normal,
            deadline: nil,
            isDone: false,
            creationDate: creationDate,
            modificationDate: nil
        )
        
        let todoItemSecond = TodoItem(
            id: "2",
            text: "Second",
            importance: .high,
            deadline: ISO8601DateFormatter().date(from: "2023-08-10T12:00:00Z"),
            isDone: true,
            creationDate: creationDate,
            modificationDate: ISO8601DateFormatter().date(from: "2023-07-10T12:00:00Z")
        )
        
        let todoItems = [todoItemFirst, todoItemSecond]
        
        let csvString = todoItems.map { $0.toCSV() }.joined(separator: "\n")
        
        let parsedTodoItems = TodoItem.parseCSV(csvString: csvString)
        
        XCTAssertEqual(parsedTodoItems.count, 2)
        
        let parsedTodoItemFirst = parsedTodoItems[0]
        XCTAssertEqual(parsedTodoItemFirst.id, "1")
        XCTAssertEqual(parsedTodoItemFirst.text, "First")
        XCTAssertEqual(parsedTodoItemFirst.importance, Importance.normal)
        XCTAssertNil(parsedTodoItemFirst.deadline)
        XCTAssertEqual(parsedTodoItemFirst.isDone, false)
        XCTAssertEqual(parsedTodoItemFirst.creationDate, ISO8601DateFormatter().date(from: "2023-06-10T12:00:00Z"))
        XCTAssertNil(parsedTodoItemFirst.modificationDate)
        
        let parsedTodoItemSecond = parsedTodoItems[1]
        XCTAssertEqual(parsedTodoItemSecond.id, "2")
        XCTAssertEqual(parsedTodoItemSecond.text, "Second")
        XCTAssertEqual(parsedTodoItemSecond.importance, Importance.high)
        XCTAssertEqual(parsedTodoItemSecond.deadline, ISO8601DateFormatter().date(from: "2023-08-10T12:00:00Z"))
        XCTAssertEqual(parsedTodoItemSecond.isDone, true)
        XCTAssertEqual(parsedTodoItemSecond.creationDate, ISO8601DateFormatter().date(from: "2023-06-10T12:00:00Z"))
        XCTAssertEqual(parsedTodoItemSecond.modificationDate, ISO8601DateFormatter().date(from: "2023-07-10T12:00:00Z"))
    }
    
}
