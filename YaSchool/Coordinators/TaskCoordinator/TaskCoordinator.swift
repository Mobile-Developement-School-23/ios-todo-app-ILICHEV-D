import Foundation
import UIKit

class TaskCoordinator: CoordinatorType, TaskCoordinatorType { // BaseCoordinator
    
    
    var navigationController: UINavigationController?
    var taskDetailsModuleInput: TaskDetailsModuleInput?
    
    func build() -> UINavigationController? {
        buildEntryPoint()
        return navigationController
    }
}

extension TaskCoordinator: TaskDetailsModuleOutput {
    
    func didAskToShowColorPicker() {
        showColorPicker()
    }
}

private extension TaskCoordinator {
    
    func buildEntryPoint() {
        let module = TaskDetailsAssembly().build(moduleOutput: self, filename: "example", type: .json)
        taskDetailsModuleInput = module.1
        self.navigationController = UINavigationController(rootViewController: module.0)
    }
    
    func showColorPicker() {
        let module = ColorPickerAssembly.build(moduleOutput: self)
        navigationController?.pushViewController(module, animated: true)
    }
    
}

extension TaskCoordinator: ColorPickerModuleOutput {
    
    func didSelectTodoItemColor(string: String) {
        taskDetailsModuleInput?.setHexColor(hexString: string)
    }
    
}
