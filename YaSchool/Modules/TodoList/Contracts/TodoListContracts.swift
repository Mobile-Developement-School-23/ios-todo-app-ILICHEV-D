import Foundation
import TodoItem

protocol TodoListModuleInput {
    @MainActor func reloadItems()
}

protocol TodoListModuleOutput {
    @MainActor func didAskToShowTaskDetails(task: TodoItem?)
}

protocol TodoListViewInput: AnyObject {
    @MainActor func configure(_ model: [TodoItem], completedTasksIsHidden: Bool, completedTasksCount: Int)
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
    func obtainTasks() async throws -> [TodoItem]
    func deleteTask(id: String) async -> [TodoItem]
    func saveTask(todoItem: TodoItem)
    func checkTask(id: String) -> [TodoItem]
}
