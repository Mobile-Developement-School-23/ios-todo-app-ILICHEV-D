import Foundation

protocol TodoListModuleInput {
    func reloadItems()
}

protocol TodoListModuleOutput {
    func didAskToShowTaskDetails(task: TodoItem?)
}

protocol TodoListViewInput: AnyObject {
    func configure(_ model: [TodoItem], completedTasksIsHidden: Bool, completedTasksCount: Int)
}

protocol TodoListViewOutput {
    func viewDidLoad()

    func deleteButtonTapped(index: Int)
    func infoButtonTapped(index: Int)
    func checkButtonTapped(index: Int)
    func addNewTaskButtonTapped()
    func toggleCompletedTasksVisibility()

}

protocol TodoListInteractorInput {
    func obtainTasks() -> [TodoItem]
    func deleteTask(id: String) -> [TodoItem]
    func saveTask(todoItem: TodoItem)
    func checkTask(id: String) -> [TodoItem]
}
