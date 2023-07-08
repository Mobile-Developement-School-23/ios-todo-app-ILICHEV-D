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
    
    func createTable() {
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
        createTable()
        cleanTable()
                
        for item in todoItems {
            var replaceStatement: OpaquePointer? = nil
            let replaceStatementString = "REPLACE INTO TodoItems (id, text, done, created_at, last_updated_by, importance, deadline, changed_at, color) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);"
            
            if sqlite3_prepare_v2(db, replaceStatementString, -1, &replaceStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(replaceStatement, 1, (item.id as NSString).utf8String, -1, nil)
                sqlite3_bind_text(replaceStatement, 2, (item.text as NSString).utf8String, -1, nil)
                sqlite3_bind_int(replaceStatement, 3, item.isDone ? 1 : 0)
                sqlite3_bind_int64(replaceStatement, 4, Int64(item.creationDate.timeIntervalSince1970))
                sqlite3_bind_text(replaceStatement, 5, (UIDevice.current.identifierForVendor?.uuidString as NSString?)?.utf8String, -1, nil)
                sqlite3_bind_text(replaceStatement, 6, (item.importance.rawValue as NSString).utf8String, -1, nil)
                if let deadline = item.deadline {
                    sqlite3_bind_int64(replaceStatement, 7, Int64(deadline.timeIntervalSince1970))
                } else {
                    sqlite3_bind_null(replaceStatement, 7)
                }
                if let modificationDate = item.modificationDate {
                    sqlite3_bind_int64(replaceStatement, 8, Int64(modificationDate.timeIntervalSince1970))
                } else {
                    sqlite3_bind_int64(replaceStatement, 8, Int64(item.creationDate.timeIntervalSince1970))
                }
                sqlite3_bind_text(replaceStatement, 9, (item.color as NSString?)?.utf8String, -1, nil)
                
                if sqlite3_step(replaceStatement) != SQLITE_DONE {
                    print("Failed to replace item: \(item.id)")
                }
//                else {
//                    print("Could not replace row.")
//                }
                
            } else {
                print("Replace error")
            }
            
            sqlite3_finalize(replaceStatement)
        }
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
