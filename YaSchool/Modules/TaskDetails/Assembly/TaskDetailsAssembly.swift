import UIKit
import FileCache
import TodoItem

class TaskDetailsAssembly { // Assembly

    func build(
        moduleOutput: TaskDetailsModuleOutput?,
        task: TodoItem?,
        filename: String,
        type: FileType
    ) -> (UIViewController, TaskDetailsModuleInput) {
        let view = TaskDetailsViewController()
        let interactor = TaskDetailsInteractor(fileCashe: FileCacheAssembly.build(filename: filename, type: type))
        let presenter = TaskDetailsPresenter()
        presenter.currentTask = task
        presenter.output = moduleOutput
        presenter.interactor = interactor
        presenter.view = view
        view.output = presenter
        return (view, presenter)
    }
}
