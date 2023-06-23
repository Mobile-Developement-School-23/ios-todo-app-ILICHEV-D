import Foundation

protocol TaskDetailsModuleInput {
    func setHexColor(hexString: String)
}

protocol TaskDetailsModuleOutput {
    func didAskToShowColorPicker()
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
    func obtainRandomTask() -> TodoItem?
    func deleteTask(todoItem: TodoItem)
    func saveTask(todoItem: TodoItem)
}

