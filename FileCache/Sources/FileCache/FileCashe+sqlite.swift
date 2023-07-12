import Foundation
import TodoItem
import SQLite3
import UIKit

extension FileCache {
    
    func openDatabase(filename: String) -> OpaquePointer? {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("\(filename).sqlite")
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
            return nil
        } else {
            print("Successfully opened database: \(filename).sqlite")
            return db
        }
    }
    
    func initTable() {
        var createTableStatement: OpaquePointer? = nil
        let createTableQuery = "CREATE TABLE IF NOT EXISTS TodoItems (id TEXT PRIMARY KEY, text TEXT, done INTEGER, created_at INTEGER, last_updated_by TEXT, importance TEXT, deadline INTEGER, changed_at INTEGER, color TEXT);"
        
        if sqlite3_prepare_v2(db, createTableQuery, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Table initialized")
            } else {
                print("Table didn't init")
            }
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func save() {
        initTable()
        cleanTable()
        
        for item in todoItems {
            insert(item)
        }
    }
    
    func insert(_ item: TodoItem) {
        var insertStatement: OpaquePointer? = nil
        let insertStatementString = "INSERT INTO TodoItems (id, text, done, created_at, last_updated_by, importance, deadline, changed_at, color) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);"
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (item.id as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (item.text as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 3, item.isDone ? 1 : 0)
            sqlite3_bind_int64(insertStatement, 4, Int64(item.creationDate.timeIntervalSince1970))
            sqlite3_bind_text(insertStatement, 5, (UIDevice.current.identifierForVendor?.uuidString as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, (item.importance.rawValue as NSString).utf8String, -1, nil)
            if let deadline = item.deadline {
                sqlite3_bind_int64(insertStatement, 7, Int64(deadline.timeIntervalSince1970))
            } else {
                sqlite3_bind_null(insertStatement, 7)
            }
            if let modificationDate = item.modificationDate {
                sqlite3_bind_int64(insertStatement, 8, Int64(modificationDate.timeIntervalSince1970))
            } else {
                sqlite3_bind_int64(insertStatement, 8, Int64(item.creationDate.timeIntervalSince1970))
            }
            sqlite3_bind_text(insertStatement, 9, (item.color as NSString?)?.utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) != SQLITE_DONE {
                print("Failed to insert item: \(item.id)")
            } else {
                print("Successfully inserted item: \(item.id)")
            }
            
        } else {
            print("INSERT statement could not be prepared.")
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    func update(_ item: TodoItem) {
        var updateStatement: OpaquePointer? = nil
        let updateStatementString = "UPDATE TodoItems SET text = ?, done = ?, created_at = ?, last_updated_by = ?, importance = ?, deadline = ?, changed_at = ?, color = ? WHERE id = ?;"
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (item.text as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 2, item.isDone ? 1 : 0)
            sqlite3_bind_int64(updateStatement, 3, Int64(item.creationDate.timeIntervalSince1970))
            sqlite3_bind_text(updateStatement, 4, (UIDevice.current.identifierForVendor?.uuidString as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 5, (item.importance.rawValue as NSString).utf8String, -1, nil)
            if let deadline = item.deadline {
                sqlite3_bind_int64(updateStatement, 6, Int64(deadline.timeIntervalSince1970))
            } else {
                sqlite3_bind_null(updateStatement, 6)
            }
            if let modificationDate = item.modificationDate {
                sqlite3_bind_int64(updateStatement, 7, Int64(modificationDate.timeIntervalSince1970))
            } else {
                sqlite3_bind_int64(updateStatement, 7, Int64(item.creationDate.timeIntervalSince1970))
            }
            sqlite3_bind_text(updateStatement, 8, (item.color as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 9, (item.id as NSString).utf8String, -1, nil)
            
            if sqlite3_step(updateStatement) != SQLITE_DONE {
                print("Failed to update item: \(item.id)")
            } else {
                print("Successfully updated item: \(item.id)")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        
        sqlite3_finalize(updateStatement)
    }
    
    func delete(_ item: TodoItem) {
        var deleteStatement: OpaquePointer? = nil
        let deleteStatementString = "DELETE FROM TodoItems WHERE id = ?;"
        
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(deleteStatement, 1, (item.id as NSString).utf8String, -1, nil)
            
            if sqlite3_step(deleteStatement) != SQLITE_DONE {
                print("Failed to delete item: \(item.id)")
            } else {
                print("Successfully deleted item: \(item.id)")
            }
            
        } else {
            print("DELETE statement could not be prepared.")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    
    
    func load() -> [TodoItem]? {
        let selectQuery = "SELECT id, text, done, created_at, last_updated_by, importance, deadline, changed_at, color FROM TodoItems;"
        var queryStatement: OpaquePointer? = nil
        var loadedItems: [TodoItem] = []

        if sqlite3_prepare_v2(db, selectQuery, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(queryStatement, 0))
                let text = String(cString: sqlite3_column_text(queryStatement, 1))
                let isDone = sqlite3_column_int(queryStatement, 2) == 1
                let creationDateInt64 = sqlite3_column_int64(queryStatement, 3)
                let creationDate = Date(timeIntervalSince1970: TimeInterval(creationDateInt64))
                let _ = String(cString: sqlite3_column_text(queryStatement, 4))
                let importanceString = String(cString: sqlite3_column_text(queryStatement, 5))
                let importance = Importance(rawValue: importanceString) ?? .normal

                let deadlineInt64 = sqlite3_column_int64(queryStatement, 6)
                let deadline: Date? = deadlineInt64 != 0 ? Date(timeIntervalSince1970: TimeInterval(deadlineInt64)) : nil

                let changedAtInt64 = sqlite3_column_int64(queryStatement, 7)
                let changedAt: Date? = changedAtInt64 != 0 ? Date(timeIntervalSince1970: TimeInterval(changedAtInt64)) : nil

                let color: String? = sqlite3_column_text(queryStatement, 8).flatMap { String(cString: $0) }

                let item = TodoItem(id: id, text: text, importance: importance, deadline: deadline, isDone: isDone, creationDate: creationDate, modificationDate: changedAt, color: color)
                loadedItems.append(item)
            }
        } else {
            print("Table doesn't exist yet")
        }

        sqlite3_finalize(queryStatement)
        return loadedItems
    }
    
    
    private func cleanTable() {
        let deleteQuery = "DELETE FROM TodoItems;"
        if sqlite3_exec(db, deleteQuery, nil, nil, nil) != SQLITE_OK {
            print("Failed to delete")
            return
        }
    }
    
    private func closeDatabase(_ db: OpaquePointer) {
        if sqlite3_close(db) != SQLITE_OK {
            print("Failed to close database")
        } else {
            print("Success to close database")
        }
    }
    
}
