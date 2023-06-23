import UIKit

class TaskDetailsAssembly { // Assembly
    
    func build(moduleOutput: TaskDetailsModuleOutput?, filename: String, type: FileType) -> (UIViewController, TaskDetailsModuleInput) {
        let view = TaskDetailsViewController()
        let interactor = TaskDetailsInteractor(fileCashe: FileCacheAssembly.build(filename: filename, type: type))
        let presenter = TaskDetailsPresenter()
        presenter.output = moduleOutput
        presenter.interactor = interactor
        presenter.view = view
        view.output = presenter
        return (view, presenter)
    }
}
