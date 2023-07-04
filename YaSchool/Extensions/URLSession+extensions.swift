import Foundation

public extension URLSession {

    func data(with request: URLRequest) async throws -> (Data, URLResponse) {
        let sessionTask = SessionTask()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                Task {
                    await sessionTask.start(request, on: self) { data, response, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let data = data, let response = response {
                            continuation.resume(returning: (data, response))
                        } else {
                            continuation.resume(throwing: URLError(.cannotLoadFromNetwork))
                        }
                    }
                }
                return
            }
        } onCancel: {
            Task { await sessionTask.cancel() }
        }
    }
    

}

private extension URLSession {

    actor SessionTask {

        var state: State = .ready

        func start(_ request: URLRequest, on session: URLSession, completionHandler: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void) {
            if case .cancelled = state {
                completionHandler(nil, nil, CancellationError())
                return
            }

            let task = session.dataTask(with: request, completionHandler: completionHandler)

            state = .executing(task)
            task.resume()
        }

        func cancel() {
            if case .executing(let task) = state {
                task.cancel()
            }
            state = .cancelled
        }

    }

    enum State {
        case ready
        case executing(URLSessionTask)
        case cancelled
    }

}
