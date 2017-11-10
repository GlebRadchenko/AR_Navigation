//___FILEHEADER___

import Foundation

protocol ___VARIABLE_moduleName___InteractorInput: class {
    
}

protocol ___VARIABLE_moduleName___InteractorOutput: class {
    
}

class ___VARIABLE_moduleName___Interactor: Interactor {
    typealias Presenter = ___VARIABLE_moduleName___InteractorOutput
    weak var output: Presenter!
    
    deinit { debugPrint("\(type(of: self)) deinited") }
}

extension ___VARIABLE_moduleName___Interactor: ___VARIABLE_moduleName___InteractorInput {
    
}
