import Foundation
import FileCache
import TodoItem

class TaskDetailsPresenter {

    // MARK: - Weak properties
    weak var view: TaskDetailsViewInput?

    var output: TaskDetailsModuleOutput?

    var currentTask: TodoItem?

}

// MARK: Private
extension TaskDetailsPresenter {

}

// MARK: Module Input
extension TaskDetailsPresenter: TaskDetailsModuleInput {

    @MainActor func setHexColor(hexString: String) {
        view?.colorText(hexString)
    }

}

// MARK: View Output
extension TaskDetailsPresenter: TaskDetailsViewOutput {

    @MainActor func viewDidLoad() {
        loadData()
    }
    
    @MainActor func deleteButtonTapped() {
        if let currentTask = currentTask {
            output?.didAskToRemoveItem(item: currentTask)
        } else {
            output?.didAskToReloadItems()
        }
    }

    @MainActor func saveButtonTapped(text: String, importance: Importance, deadline: Date?, color: String?) {
        if let task = currentTask {
            let todoItem = TodoItem(
                id: task.id,
                text: text,
                importance: importance,
                deadline: deadline,
                isDone: task.isDone,
                creationDate: task.creationDate,
                modificationDate: Date(),
                color: color
            )
            output?.didAskToUpdateItem(item: todoItem)
        } else {
            let todoItem = TodoItem(
                text: text,
                importance: importance,
                deadline: deadline,
                isDone: false,
                creationDate: Date(),
                color: color
            )
            output?.didAskToSaveItem(item: todoItem)
        }
    }

    @MainActor func colorPickerTapped() {
        output?.didAskToShowColorPicker()
    }

    @MainActor func cancelButtonTapped() {
        output?.didAskToCloseTaskDetails()
    }

}

private extension TaskDetailsPresenter {

    @MainActor func loadData() {
        view?.configure(currentTask)
    }

}
