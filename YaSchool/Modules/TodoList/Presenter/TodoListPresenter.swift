import Foundation
import TodoItem
import CocoaLumberjackSwift

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

    @MainActor func reloadItems() {
        self.tasks = interactor?.obtainTasksLocally() ?? []
        view?.setStatus(.loading)
        
        guard !isDirty else {
            return reloadDirtyList()
        }
        
        Task.detached(operation: { [weak self] in
            do {
                if let tasks = try await self?.interactor?.obtainTasks() {
                    self?.tasks = tasks
                    self?.interactor?.setLocalItems(tasks)
                    await self?.reloadView()
                    await self?.view?.setStatus(.basic)
                }
            } catch {
                await self?.view?.setStatus(.dirty)
                self?.interactor?.setItemsDirty(true)
            }
        })
    }
    
    @MainActor func removeItem(_ item: TodoItem) {
        removeItem(item.id)
    }
    
    @MainActor func saveItem(_ item: TodoItem) {
        tasks = interactor?.saveTaskLocally(item: item) ?? tasks
        view?.setStatus(.loading)
        reloadView()
        
        guard !isDirty else {
            return reloadDirtyList()
        }
        
        Task.detached(operation: { [weak self] in
            do {
                try await self?.interactor?.saveTask(item: item)
                await self?.reloadView()
                await self?.view?.setStatus(.basic)
            } catch {
                await self?.view?.setStatus(.dirty)
                self?.interactor?.setItemsDirty(true)
            }
        })
    }
    
    @MainActor func updateItem(_ item: TodoItem) {
        tasks = interactor?.saveTaskLocally(item: item) ?? tasks
        view?.setStatus(.loading)
        reloadView()
        
        guard !isDirty else {
            return reloadDirtyList()
        }
        
        Task.detached(operation: { [weak self] in
            do {
                try await self?.interactor?.updateTask(item: item)
                await self?.reloadView()
                await self?.view?.setStatus(.basic)
            } catch {
                await self?.view?.setStatus(.dirty)
                self?.interactor?.setItemsDirty(true)
            }
        })
    }

}

// MARK: View Output
extension TodoListPresenter: TodoListViewOutput {

    @MainActor func viewDidLoad() {
        reloadItems()
    }

    @MainActor func deleteButtonTapped(index: Int) {
        let id = tasks[index].id
        removeItem(id)
    }

    @MainActor func infoButtonTapped(index: Int) {
        output?.didAskToShowTaskDetails(task: tasks[index])
    }

    @MainActor func checkButtonTapped(index: Int) {
        let id = tasks[index].id
        tasks = interactor?.checkTaskLocally(id: id) ?? tasks
        view?.setStatus(.loading)
        reloadView()
        
        guard !isDirty else {
            return reloadDirtyList()
        }
        
        Task.detached(operation: { [weak self] in
            do {
                try await self?.interactor?.checkTask(id: id)
                await self?.reloadView()
                await self?.view?.setStatus(.basic)
            } catch {
                await self?.view?.setStatus(.dirty)
                self?.interactor?.setItemsDirty(true)
            }
        })
    }

    @MainActor func addNewTaskButtonTapped() {
        output?.didAskToShowTaskDetails(task: nil)
    }

    @MainActor func toggleCompletedTasksVisibility() {
        completedTasksIsHidden.toggle()
        reloadView()
    }

}

private extension TodoListPresenter {
    
    private var isDirty: Bool {
        (interactor?.isListDirty()) ?? false
    }
    
    @MainActor func reloadView() {
        tasks = interactor?.obtainTasksLocally() ?? []
        tasks.sort { $0.creationDate < $1.creationDate }
        let activeTasks = tasks.filter { !$0.isDone }
        let completedTasksCount = tasks.count - activeTasks.count
        if completedTasksIsHidden {
            tasks = activeTasks
        }
        view?.configure(tasks, completedTasksIsHidden: completedTasksIsHidden, completedTasksCount: completedTasksCount)
    }
    
    @MainActor func removeItem(_ id: String) {
        tasks = interactor?.deleteTaskLocally(id: id) ?? tasks
        view?.setStatus(.loading)
        reloadView()

        guard !isDirty else {
            return reloadDirtyList()
        }
        
        Task.detached(operation: { [weak self] in
            do {
                try await self?.interactor?.deleteTask(id: id)
                await self?.reloadView()
                await self?.view?.setStatus(.basic)
            } catch {
                await self?.view?.setStatus(.dirty)
                self?.interactor?.setItemsDirty(true)
            }
        })
    }
    
    @MainActor func reloadDirtyList() {
        Task.detached(operation: { [weak self] in
            do {
                let items = try await self?.interactor?.updateItems()
                self?.interactor?.setLocalItems(items ?? [])
                await self?.reloadView()
                await self?.view?.setStatus(.basic)
                self?.interactor?.setItemsDirty(false)
            } catch {
                await self?.view?.setStatus(.dirty)
                self?.interactor?.setItemsDirty(true)
            }
        })
    }
    

}
