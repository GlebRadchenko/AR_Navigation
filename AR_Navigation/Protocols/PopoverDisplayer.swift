//
//  PopoverDisplayer.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 11/13/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

public protocol PopoverDisplayer: class, UIPopoverPresentationControllerDelegate {
    func present(vc: UIViewController, popoverSize: CGSize?, from source: UIView?, arrowDirections: UIPopoverArrowDirection, completion: (() -> Void)?)
}

extension UIViewController: PopoverDisplayer {
    public func present(vc: UIViewController,
                        popoverSize: CGSize?,
                        from source: UIView?,
                        arrowDirections: UIPopoverArrowDirection = .any,
                        completion: (() -> Void)?) {
        
        vc.modalPresentationStyle = .popover
        guard let presentationController = vc.popoverPresentationController else {
            debugPrint("No presentationController")
            return
        }
        
        if let size = popoverSize {
            vc.preferredContentSize = size
        }
        
        presentationController.delegate = self
        
        if let sourceRect = source?.bounds {
            presentationController.sourceRect = sourceRect
        }
        presentationController.permittedArrowDirections = arrowDirections
        presentationController.sourceView = source
        
        present(vc, animated: true, completion: completion)
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
