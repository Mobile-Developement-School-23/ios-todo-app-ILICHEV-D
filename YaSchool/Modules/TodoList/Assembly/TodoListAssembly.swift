import UIKit
import FileCache

class TodoListAssembly {

    @MainActor func build(
        moduleOutput: TodoListModuleOutput?, filename: String, type: FileType
    ) -> (UIViewController, TodoListModuleInput) {
        let view = TodoListViewController()
        let interactor = TodoListInteractor(fileCashe: FileCacheAssembly.build(filename: filename, type: type), networkService: DefaultNetworkingService.shared)
        let presenter = TodoListPresenter()
        presenter.output = moduleOutput
        presenter.interactor = interactor
        presenter.view = view
        view.output = presenter
        return (view, presenter)
    }
}
