import Foundation

protocol ColorPickerModuleInput {}

protocol ColorPickerModuleOutput {
    func didSelectTodoItemColor(string: String)
}

protocol ColorPickerViewInput: AnyObject {}

protocol ColorPickerViewOutput: AnyObject {
    func saveButtonTapped(hexString: String)
}
