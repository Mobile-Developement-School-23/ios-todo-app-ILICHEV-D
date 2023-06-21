import Foundation

class TaskDetailsPresenter {
    
    // MARK: - Weak properties
    var view: TaskDetailsViewInput?
    
    var interactor: TaskDetailsInteractorInput?
    var output: TaskDetailsModuleOutput?
    
    private var currentTask: TodoItem?
}

// MARK: Private
extension TaskDetailsPresenter {
    
}

// MARK: Module Input
extension TaskDetailsPresenter: TaskDetailsModuleInput {
    
}

// MARK: View Output
extension TaskDetailsPresenter: TaskDetailsViewOutput {
    
    func viewDidLoad() {
        loadData()
    }
    
    func deleteButtonTapped() {
        if let currentTask = currentTask {
            interactor?.deleteTask(todoItem: currentTask)
        }
        loadData()
    }
    
    func cancelButtonTapped() { }
    
    func saveButtonTapped(text: String, importance: Importance, deadline: Date?) {
        interactor?.saveTask(todoItem: TodoItem(text: text, importance: importance, deadline: deadline, isDone: false, creationDate: Date()))
        loadData()
    }
}

private extension TaskDetailsPresenter {
    
    func loadData() {
        currentTask = interactor?.obtainRandomTask()
        view?.configure(currentTask)
    }
    
}
