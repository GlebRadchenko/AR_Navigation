//___FILEHEADER___

import Foundation

protocol ___VARIABLE_moduleName___ModuleInput: ModuleInput {
    
}

class ___VARIABLE_moduleName___Presenter: Presenter, ___VARIABLE_moduleName___ModuleInput {
    
    typealias View = ___VARIABLE_moduleName___View
    typealias Router = ___VARIABLE_moduleName___Router
    typealias Interactor = ___VARIABLE_moduleName___Interactor
    
    var interactor: Interactor!
    var router: Router!
    var view: View!
    
    deinit { debugPrint("\(type(of: self)) deinited") }
}


// MARK: - ___VARIABLE_moduleName___ViewOutput
extension ___VARIABLE_moduleName___Presenter: ___VARIABLE_moduleName___ViewOutput {
    func viewDidLoad() {
        
    }
}

// MARK: - ___VARIABLE_moduleName___InteractorOutput
extension ___VARIABLE_moduleName___Presenter: ___VARIABLE_moduleName___InteractorOutput {
    
}
