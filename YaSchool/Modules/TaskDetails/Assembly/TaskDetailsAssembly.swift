import UIKit
import FileCache
import TodoItem

class TaskDetailsAssembly { // Assembly

    @MainActor func build(
        moduleOutput: TaskDetailsModuleOutput?,
        task: TodoItem?,
        filename: String,
        type: FileType
    ) -> (UIViewController, TaskDetailsModuleInput) {
        let view = TaskDetailsViewController()
        let presenter = TaskDetailsPresenter()
        presenter.currentTask = task
        presenter.output = moduleOutput
        presenter.view = view
        view.output = presenter
        return (view, presenter)
    }
}
