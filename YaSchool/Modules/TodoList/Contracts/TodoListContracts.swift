import Foundation
import TodoItem

protocol TodoListModuleInput {
    @MainActor func reloadItems()
    @MainActor func removeItem(_ item: TodoItem)
    @MainActor func saveItem(_ item: TodoItem)
    @MainActor func updateItem(_ item: TodoItem)
}

protocol TodoListModuleOutput {
    @MainActor func didAskToShowTaskDetails(task: TodoItem?)
}

protocol TodoListViewInput: AnyObject {
    @MainActor func configure(_ model: [TodoItem], completedTasksIsHidden: Bool, completedTasksCount: Int)
    @MainActor func setStatus(_ status: TodoListViewStatus)
}

protocol TodoListViewOutput {
    @MainActor func viewDidLoad()

    @MainActor func deleteButtonTapped(index: Int)
    @MainActor func infoButtonTapped(index: Int)
    @MainActor func checkButtonTapped(index: Int)
    @MainActor func addNewTaskButtonTapped()
    @MainActor func toggleCompletedTasksVisibility()

}

protocol TodoListInteractorInput {
    func obtainTasksLocally() -> [TodoItem]
    func deleteTaskLocally(id: String) -> [TodoItem]
    func checkTaskLocally(id: String) -> [TodoItem]
    func saveTaskLocally(item: TodoItem) -> [TodoItem]
    
    func obtainTasks() async throws -> [TodoItem]
    func deleteTask(id: String) async throws
    func checkTask(id: String) async throws
    func saveTask(item: TodoItem) async throws
    func updateTask(item: TodoItem) async throws
    func updateItems() async throws -> [TodoItem]

    func setLocalItems(_ items: [TodoItem])
    func setItemsDirty(_ isDirty: Bool)
    func isListDirty() -> Bool
}
