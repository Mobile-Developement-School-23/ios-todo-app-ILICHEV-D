import Foundation
import TodoItem

protocol TaskDetailsModuleInput {
    @MainActor func setHexColor(hexString: String)
}

protocol TaskDetailsModuleOutput {
    @MainActor func didAskToShowColorPicker()
    @MainActor func didAskToReloadItems()
    @MainActor func didAskToCloseTaskDetails()
}

protocol TaskDetailsViewInput: AnyObject {
    @MainActor func configure(_ model: TodoItem?)
    @MainActor func colorText(_ hextString: String)
}

protocol TaskDetailsViewOutput {
    @MainActor func viewDidLoad()

    @MainActor func deleteButtonTapped()
    @MainActor func saveButtonTapped(text: String, importance: Importance, deadline: Date?, color: String?)
    @MainActor func cancelButtonTapped()
    @MainActor func colorPickerTapped()

}

protocol TaskDetailsInteractorInput {
    func deleteTask(todoItem: TodoItem)
    func saveTask(todoItem: TodoItem)
}
