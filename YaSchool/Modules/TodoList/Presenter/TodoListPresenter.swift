import Foundation

class TodoListPresenter {
    
    // MARK: - Weak properties
    weak var view: TodoListViewInput?
    
    var interactor: TodoListInteractorInput?
    var output: TodoListModuleOutput?
    
    private var tasks: [TodoItem] = []
    private var completedTasksIsHidden = false
}

// MARK: Private
extension TodoListPresenter {
    
}

// MARK: Module Input
extension TodoListPresenter: TodoListModuleInput {
    
    func reloadItems() {
        tasks = interactor?.obtainTasks() ?? []
        reloadView()
    }
    
}

// MARK: View Output
extension TodoListPresenter: TodoListViewOutput {
    
    func viewDidLoad() {
        tasks = interactor?.obtainTasks() ?? tasks
        reloadView()
    }
    
    func deleteButtonTapped(index: Int) {
        let id = tasks[index].id
        tasks = interactor?.deleteTask(id: id) ?? tasks
        reloadView()
    }
    
    func infoButtonTapped(index: Int) {
        output?.didAskToShowTaskDetails(task: tasks[index])
    }
    
    func checkButtonTapped(index: Int) {
        let id = tasks[index].id
        tasks = interactor?.checkTask(id: id) ?? tasks
        reloadView()
    }
    
    func addNewTaskButtonTapped() {
        output?.didAskToShowTaskDetails(task: nil)
    }
    
    func toggleCompletedTasksVisibility() {
        completedTasksIsHidden.toggle()
        tasks = interactor?.obtainTasks() ?? tasks
        reloadView()
    }
    
}

private extension TodoListPresenter {
    
    func reloadView() {
        tasks.sort { $0.creationDate < $1.creationDate }
        let activeTasks = tasks.filter { !$0.isDone }
        let completedTasksCount = tasks.count - activeTasks.count
        if completedTasksIsHidden {
            tasks = activeTasks
        }
        view?.configure(tasks, completedTasksIsHidden: completedTasksIsHidden, completedTasksCount: completedTasksCount)
    }
    
}



