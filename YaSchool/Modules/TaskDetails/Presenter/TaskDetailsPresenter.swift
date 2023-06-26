import Foundation
import FileCache

class TaskDetailsPresenter {

    // MARK: - Weak properties
    weak var view: TaskDetailsViewInput?

    var interactor: TaskDetailsInteractorInput?
    var output: TaskDetailsModuleOutput?

    var currentTask: TodoItem?

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
        output?.didAskToReloadItems()
    }

    func saveButtonTapped(text: String, importance: Importance, deadline: Date?, color: String?) {
        if let task = currentTask {
            interactor?.saveTask(todoItem: TodoItem(
                id: task.id,
                text: text,
                importance: importance,
                deadline: deadline,
                isDone: task.isDone,
                creationDate: Date(),
                color: color
            ))
        } else {
            interactor?.saveTask(todoItem: TodoItem(
                text: text,
                importance: importance,
                deadline: deadline,
                isDone: false,
                creationDate: Date(),
                color: color
            ))
        }
        output?.didAskToReloadItems()
    }

    func colorPickerTapped() {
        output?.didAskToShowColorPicker()
    }

    func cancelButtonTapped() {
        output?.didAskToCloseTaskDetails()
    }

}

private extension TaskDetailsPresenter {

    func loadData() {
        view?.configure(currentTask)
    }

}
