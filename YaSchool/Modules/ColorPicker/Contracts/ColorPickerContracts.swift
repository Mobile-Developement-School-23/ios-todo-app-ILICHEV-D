import Foundation

protocol ColorPickerModuleInput {}

protocol ColorPickerModuleOutput {
    @MainActor func didSelectTodoItemColor(string: String)
}

protocol ColorPickerViewInput: AnyObject {}

protocol ColorPickerViewOutput: AnyObject {
    @MainActor func saveButtonTapped(hexString: String)
}
