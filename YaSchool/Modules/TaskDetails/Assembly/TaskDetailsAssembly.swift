import UIKit

class TaskDetailsAssembly { // Assembly
    
    func build(moduleOutput: TaskDetailsModuleOutput) -> UIViewController {
        let view = TaskDetailsViewController()
        let interactor = TaskDetailsInteractor(fileCashe: FileCacheAssembly.build(filename: "example", type: .json))
        let presenter = TaskDetailsPresenter()
        presenter.output = moduleOutput
        presenter.interactor = interactor
        presenter.view = view
        view.output = presenter
        return view
    }
}
