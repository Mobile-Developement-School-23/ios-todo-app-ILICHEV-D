import Foundation

class TaskDetailsPresenter {
    
    // MARK: - Weak properties
    weak var view: TaskDetailsViewInput?
    
    var interactor: TaskDetailsInteractorInput?
    var output: TaskDetailsModuleOutput?
    
    private var currentTask: TodoItem?
}

// MARK: Private
extension TaskDetailsPresenter {
    
}

// MARK: Module Input
extension TaskDetailsPresenter: TaskDetailsModuleInput {
    
    func setHexColor(hexString: String) {
        view?.colorText(hexString)
    }
    
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
    
    func saveButtonTapped(text: String, importance: Importance, deadline: Date?, color: String?) {
        interactor?.saveTask(todoItem: TodoItem(text: text, importance: importance, deadline: deadline, isDone: false, creationDate: Date(), color: color))
        loadData()
    }
    
    func colorPickerTapped() {
        output?.didAskToShowColorPicker()
    }
    
    func cancelButtonTapped() {}
    
}

private extension TaskDetailsPresenter {
    
    func loadData() {
        currentTask = interactor?.obtainRandomTask()
        view?.configure(currentTask)
    }
    
}
