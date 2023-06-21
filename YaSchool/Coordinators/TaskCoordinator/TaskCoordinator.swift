import Foundation
import UIKit

class TaskCoordinator: CoordinatorType, TaskCoordinatorType { // BaseCoordinator
    
    func build() -> UINavigationController {
        let module = TaskDetailsAssembly()
        return UINavigationController(rootViewController: module.build(moduleOutput: self)) 
    }
    
}

extension TaskCoordinator: TaskDetailsModuleOutput {
    
}
