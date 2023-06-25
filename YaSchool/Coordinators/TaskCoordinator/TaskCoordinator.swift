import Foundation
import UIKit

class TaskCoordinator: CoordinatorType, TaskCoordinatorType { // BaseCoordinator

    var navigationController: UINavigationController?
    var modalNavigationController: UINavigationController?
    var todoListModuleInput: TodoListModuleInput?
    var taskDetailsModuleInput: TaskDetailsModuleInput?

    func build() -> UINavigationController? {
        buildEntryPoint()
        return navigationController
    }
}

extension TaskCoordinator: TodoListModuleOutput {

    func didAskToShowTaskDetails(task: TodoItem?) {
        showTaskDetails(task: task)
    }

}

extension TaskCoordinator: TaskDetailsModuleOutput {

    func didAskToShowColorPicker() {
        showColorPicker()
    }

    func didAskToReloadItems() {
        modalNavigationController?.dismiss(animated: true) {
            self.modalNavigationController = nil
        }
        todoListModuleInput?.reloadItems()
    }

    func didAskToCloseTaskDetails() {
        modalNavigationController?.dismiss(animated: true) {
            self.modalNavigationController = nil
        }
    }

}

extension TaskCoordinator: ColorPickerModuleOutput {

    func didSelectTodoItemColor(string: String) {
        taskDetailsModuleInput?.setHexColor(hexString: string)
    }

}

private extension TaskCoordinator {

    func buildEntryPoint() {
        let module = TodoListAssembly().build(moduleOutput: self, filename: "example", type: .json)
        todoListModuleInput = module.1
        self.navigationController = UINavigationController(rootViewController: module.0)
    }

    func showColorPicker() {
        let module = ColorPickerAssembly.build(moduleOutput: self)
        modalNavigationController?.pushViewController(module, animated: true)
    }

    func showTaskDetails(task: TodoItem?) {
        let module = TaskDetailsAssembly().build(moduleOutput: self, task: task, filename: "example", type: .json)
        taskDetailsModuleInput = module.1
        modalNavigationController = UINavigationController(rootViewController: module.0)
        if let modalNavigationController = modalNavigationController {
            navigationController?.present(modalNavigationController, animated: true)
        }
    }

}
