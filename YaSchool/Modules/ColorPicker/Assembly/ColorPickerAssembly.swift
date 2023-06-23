import UIKit

class ColorPickerAssembly {
    
    static func build(moduleOutput: ColorPickerModuleOutput?) -> UIViewController {
        let view = ColorPickerViewController()
 
        let presenter = ColorPickerPresenter()
        
        presenter.view = view
        presenter.output = moduleOutput
        view.output = presenter
        
        return view
    }
    
}
