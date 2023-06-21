import Foundation

// Module Input
protocol TaskDetailsModuleInput {
    
}

// Module Output
protocol TaskDetailsModuleOutput {
    
}

// View Input
protocol TaskDetailsViewInput {
    func configure(_ model: TodoItem?)
}

// View Output
protocol TaskDetailsViewOutput {
    
    func viewDidLoad()
    
    func deleteButtonTapped()
    func saveButtonTapped(text: String, importance: Importance, deadline: Date?)
    func cancelButtonTapped()
    
}

// Interactor
protocol TaskDetailsInteractorInput {
    
    func obtainRandomTask() -> TodoItem?
    func deleteTask(todoItem: TodoItem)
    func saveTask(todoItem: TodoItem)
}

