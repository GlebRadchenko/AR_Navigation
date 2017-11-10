//___FILEHEADER___

import UIKit

protocol ___VARIABLE_moduleName___ViewInput: class {
    
}

protocol ___VARIABLE_moduleName___ViewOutput: class {
    func viewDidLoad()
}

class ___VARIABLE_moduleName___View: UIViewController, View {
    static var storyboardName: String { return "___VARIABLE_moduleName___" }
    
    typealias Presenter = ___VARIABLE_moduleName___ViewOutput
    weak var output: Presenter!
    
    deinit { debugPrint("\(type(of: self)) deinited") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        output?.viewDidLoad()
    }
}

// MARK: - ___VARIABLE_moduleName:identifier___ViewInput
extension ___VARIABLE_moduleName___View: ___VARIABLE_moduleName___ViewInput {
    
}

