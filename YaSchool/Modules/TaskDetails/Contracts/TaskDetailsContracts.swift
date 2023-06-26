import Foundation
import FileCache

protocol TaskDetailsModuleInput {
    func setHexColor(hexString: String)
}

protocol TaskDetailsModuleOutput {
    func didAskToShowColorPicker()
    func didAskToReloadItems()
    func didAskToCloseTaskDetails()
}

protocol TaskDetailsViewInput: AnyObject {
    func configure(_ model: TodoItem?)
    func colorText(_ hextString: String)
}

protocol TaskDetailsViewOutput {
    func viewDidLoad()

    func deleteButtonTapped()
    func saveButtonTapped(text: String, importance: Importance, deadline: Date?, color: String?)
    func cancelButtonTapped()
    func colorPickerTapped()

}

protocol TaskDetailsInteractorInput {
    func deleteTask(todoItem: TodoItem)
    func saveTask(todoItem: TodoItem)
}
