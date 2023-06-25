import Foundation

class ColorPickerPresenter {

    // MARK: - Weak properties
    weak var view: ColorPickerViewInput?
    var output: ColorPickerModuleOutput?

}

// MARK: Private
extension ColorPickerPresenter {

}

// MARK: Module Input
extension ColorPickerPresenter: ColorPickerModuleInput {

}

// MARK: View Output
extension ColorPickerPresenter: ColorPickerViewOutput {

    func saveButtonTapped(hesString: String) {
        output?.didSelectTodoItemColor(string: hesString)
    }

}
