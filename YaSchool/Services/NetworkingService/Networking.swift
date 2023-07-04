import Foundation
import UIKit
import SwiftUI
import TodoItem
import FileCache

public protocol NetworkingServiceProtocol {
    func getList() async throws -> [TodoItem]
    func updateList(with items: [TodoItem]) async throws -> [TodoItem]
    func obtainTodoItem(withId id: String, item: TodoItem) async throws -> TodoItem
    func createTodoItem(_ item: TodoItem) async throws -> TodoItem
    func updateTodoItem(withId id: String, item: TodoItem) async throws -> TodoItem
    func deleteTodoItem(withId id: String) async throws -> TodoItem
}

struct DefaultNetworkingService {
    
    static var shared = DefaultNetworkingService()
    
    private let storage = RevisionStorage()
    
    private let urlSession = URLSession(configuration: .default)
    
    private let baseURL = "https://beta.mrdekk.ru/todobackend"
    private let authorizationToken = "caseate"
    
}

extension DefaultNetworkingService: NetworkingServiceProtocol {
    
    func getList() async throws -> [TodoItem] {
        let endpoint = "list"
        let request = await makeRequest(endpoint, method: "GET", withRevision: false)

        return try await retryRequestWithItems(request)
    }
    
    func obtainTodoItem(withId id: String, item: TodoItem) async throws -> TodoItem {
        let endpoint = "list/\(id)"
        let request = await makeRequest(endpoint, method: "POST", body: try JSONSerialization.data(withJSONObject: ["element": item.json]), withRevision: true)
        
        return try await retryRequestWithItem(request)
    }
    
    func createTodoItem(_ item: TodoItem) async throws -> TodoItem {
        let endpoint = "list"
        let request = await makeRequest(endpoint, method: "POST", body: try JSONSerialization.data(withJSONObject: ["element": item.json]), withRevision: true)
        
        return try await retryRequestWithItem(request)
    }
    
    func updateTodoItem(withId id: String, item: TodoItem) async throws -> TodoItem {
        let endpoint = "list/\(id)"
        let request = await makeRequest(endpoint, method: "PUT", body: try JSONSerialization.data(withJSONObject: ["element": item.json]), withRevision: true)
        
        return try await retryRequestWithItem(request)

    }
    
    func deleteTodoItem(withId id: String) async throws -> TodoItem {
        let endpoint = "list/\(id)"
        let request = await makeRequest(endpoint, method: "DELETE", withRevision: true)
        
        return try await retryRequestWithItem(request)
    }
    
    
    func updateList(with items: [TodoItem]) async throws -> [TodoItem] {
        let endpoint = "list"
        let jsonItems = items.map { $0.json }
        let request = await makeRequest(endpoint, method: "PATCH", body: try JSONSerialization.data(withJSONObject: ["list": jsonItems]), withRevision: true)
        
        return try await retryRequestWithItems(request)
    }
    
}

private extension DefaultNetworkingService {
    
    func makeRequest(_ endpoint: String, method: String, body: Data? = nil, withRevision: Bool) async -> URLRequest {
        let url = URL(string: "\(baseURL)/\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.setValue("Bearer \(authorizationToken)", forHTTPHeaderField: "Authorization")
        
        if withRevision {
            let lastKnownRevision = await storage.getRevision()
            var headers = request.allHTTPHeaderFields ?? [:]
            headers["X-Last-Known-Revision"] = "\(lastKnownRevision)"
            request.allHTTPHeaderFields = headers
        }
        return request
    }
    
    func retryRequestWithItem(_ request: URLRequest, retryCount: Int = 0) async throws -> TodoItem {
        let delay = min(Double(2.0 * pow(1.5, Double(retryCount))), 120.0)
        let jitter = Double.random(in: 0.0...0.05)
        let totalDelay = delay * (1.0 + jitter)
        
        try await Task.sleep(nanoseconds: UInt64(totalDelay * 1_000_000))
        
        do {
            var updatedRequest = request
            let lastKnownRevision = await storage.getRevision()
            var headers = request.allHTTPHeaderFields ?? [:]
            headers["X-Last-Known-Revision"] = "\(lastKnownRevision)"
            updatedRequest.allHTTPHeaderFields = headers
            
            let (data, _) = try await urlSession.data(with: updatedRequest)
            return try await parseTodoItem(from: data)
        } catch {
            if retryCount < 3 {
                return try await retryRequestWithItem(request, retryCount: retryCount + 1)
            }
            throw error
        }
    }
    
    func retryRequestWithItems(_ request: URLRequest, retryCount: Int = 0) async throws -> [TodoItem] {
        let delay = min(Double(2.0 * pow(1.5, Double(retryCount))), 120.0)
        let jitter = Double.random(in: 0.0...0.05)
        let totalDelay = delay * (1.0 + jitter)
        
        try await Task.sleep(nanoseconds: UInt64(totalDelay * 1_000_000))
        
        do {
            var updatedRequest = request
            let lastKnownRevision = await storage.getRevision()
            var headers = request.allHTTPHeaderFields ?? [:]
            headers["X-Last-Known-Revision"] = "\(lastKnownRevision)"
            updatedRequest.allHTTPHeaderFields = headers

            let (data, _) = try await urlSession.data(with: updatedRequest)
            return try await parseTodoItems(from: data)
        } catch {
            print("CATCH", retryCount)
            if retryCount < 3 {
                return try await retryRequestWithItems(request, retryCount: retryCount + 1)
            }
            throw error
        }
    }
    
    func parseTodoItems(from data: Data) async throws -> [TodoItem] {
        let json = try JSONSerialization.jsonObject(with: data)
        guard let jsonArray = json as? [String: Any],
              let revision = jsonArray["revision"] as? Int,
              let list = jsonArray["list"] as? [[String: Any]]
        else {
            throw URLError(.cannotDecodeContentData)
        }
        
        var todoItems: [TodoItem] = []
        for jsonObject in list {
            guard let todoItem = TodoItem.parse(json: jsonObject) else {
                throw URLError(.cannotDecodeContentData)
            }
            todoItems.append(todoItem)
        }
        await storage.updateRevision(newRevision: revision)
        return todoItems
    }
    
    func parseTodoItem(from data: Data) async throws -> TodoItem {
        let json = try JSONSerialization.jsonObject(with: data)
        guard let jsonArray = json as? [String: Any],
              let revision = jsonArray["revision"] as? Int,
              let element = jsonArray["element"] as? [String: Any],
              let todoItem = TodoItem.parse(json: element)
        else {
            throw URLError(.cannotDecodeContentData)
        }
        await storage.updateRevision(newRevision: revision)
        return todoItem
    }
    
}
