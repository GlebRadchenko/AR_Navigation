//___FILEHEADER___

import UIKit

protocol ___VARIABLE_moduleName___RouterInput: class {
    
}

class ___VARIABLE_moduleName___Router: Router, ___VARIABLE_moduleName___RouterInput {
    typealias ModuleView = ___VARIABLE_moduleName___View
    
    deinit { debugPrint("\(type(of: self)) deinited") }
    
    static func moduleInput<T>() throws -> T {
        
        let view: ModuleView = try UIStoryboard.extractView()
        let presenter = ___VARIABLE_moduleName___Presenter()
        let interactor = ___VARIABLE_moduleName___Interactor()
        let router = ___VARIABLE_moduleName___Router()
        
        view.output = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.output = presenter
        
        return try presenter.specific()
    }
}

