import Foundation
import TodoItem
import UIKit

class TaskCoordinator: CoordinatorType, TaskCoordinatorType { // BaseCoordinator

    var navigationController: UINavigationController?
    var modalNavigationController: UINavigationController?
    var todoListModuleInput: TodoListModuleInput?
    var taskDetailsModuleInput: TaskDetailsModuleInput?

    @MainActor func build() -> UINavigationController? {
        buildEntryPoint()
        return navigationController
    }
}

extension TaskCoordinator: TodoListModuleOutput {

    @MainActor func didAskToShowTaskDetails(task: TodoItem?) {
        showTaskDetails(task: task)
    }

}

extension TaskCoordinator: TaskDetailsModuleOutput {

    @MainActor func didAskToShowColorPicker() {
        showColorPicker()
    }

    @MainActor func didAskToReloadItems() {
        modalNavigationController?.dismiss(animated: true) {
            self.modalNavigationController = nil
        }
        todoListModuleInput?.reloadItems()
    }

    @MainActor func didAskToCloseTaskDetails() {
        modalNavigationController?.dismiss(animated: true) {
            self.modalNavigationController = nil
        }
    }

}

extension TaskCoordinator: ColorPickerModuleOutput {

    @MainActor func didSelectTodoItemColor(string: String) {
        taskDetailsModuleInput?.setHexColor(hexString: string)
    }

}

private extension TaskCoordinator {

    @MainActor func buildEntryPoint() {
        let module = TodoListAssembly().build(moduleOutput: self, filename: "example", type: .json)
        todoListModuleInput = module.1
        self.navigationController = UINavigationController(rootViewController: module.0)
    }

    @MainActor func showColorPicker() {
        let module = ColorPickerAssembly.build(moduleOutput: self)
        modalNavigationController?.pushViewController(module, animated: true)
    }

    @MainActor func showTaskDetails(task: TodoItem?) {
        let module = TaskDetailsAssembly().build(moduleOutput: self, task: task, filename: "example", type: .json)
        taskDetailsModuleInput = module.1
        modalNavigationController = UINavigationController(rootViewController: module.0)
        if let modalNavigationController = modalNavigationController {
            navigationController?.present(modalNavigationController, animated: true)
        }
    }

}
