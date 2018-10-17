//
//  KeyboardEventsManager.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

class KeyboardEventsManager: NSObject {
    
    var onWillShow: ((_ keyboardFrame: CGRect, _ duration: TimeInterval) -> Void)?
    var onWillHide: ((_ duration: TimeInterval) -> Void)?
    var onWillChange: ((_ keyboardFrame: CGRect, _ duration: TimeInterval) -> Void)?
    
    override init() {
        super.init()
        subscribe()
    }
    
    deinit { unsubscribe() }
    
    public func subscribe() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }
    
    public func unsubscribe() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = keyboardEndFrame(from: notification) else { return }
        guard let duration = keyboardAnimationDuration(from: notification) else { return }
        
        onWillShow?(keyboardFrame, duration)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        guard let duration = keyboardAnimationDuration(from: notification) else { return }
        onWillHide?(duration)
    }
    
    @objc func keyboardWillChangeFrame(notification: Notification) {
        guard let keyboardEndFrame = keyboardEndFrame(from: notification), let keyboardBeginFrame = keyboardBeginFrame(from: notification) else {
            return
        }
        
        guard let duration = keyboardAnimationDuration(from: notification) else { return }
        
        if keyboardEndFrame.height != keyboardBeginFrame.height {
            onWillChange?(keyboardEndFrame, duration)
        }
    }
    
    func keyboardBeginFrame(from notification: Notification) -> CGRect? {
        let userInfo = notification.userInfo
        let value = userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue
        return value?.cgRectValue
    }
    
    func keyboardEndFrame(from notification: Notification) -> CGRect? {
        let userInfo = notification.userInfo
        let value = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        return value?.cgRectValue
    }
    
    func keyboardAnimationDuration(from notification: Notification) -> TimeInterval? {
        let userInfo = notification.userInfo
        let value = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        return value?.doubleValue
    }
}

