//
//  NotificationDisplayer.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 11/22/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

protocol NotificationDisplayerInput {
    func displayNotification(message: String)
}

protocol NotificationDisplayer: class, NotificationDisplayerInput {
    weak var notificationView: NotificationView? { get }
    var topNotificationViewConstraint: NSLayoutConstraint? { get set }
    
    var messageQueue: [String] { get set }
}

extension NotificationDisplayer where Self: UIViewController {
    weak var notificationView: NotificationView? {
        return view.subviews.first(where: { $0 is NotificationView }) as? NotificationView
    }
    
    var notificationViewPresented: Bool {
        guard let constraint = topNotificationViewConstraint else {
            return false
        }
        
        return constraint.constant >= -25
    }
    
    func addNotificationView() {
        guard self.notificationView == nil else { return }
        
        let notificationView = NotificationView()
        notificationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(notificationView)
        
        notificationView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        notificationView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        notificationView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        topNotificationViewConstraint = notificationView.topAnchor.constraint(equalTo: view.topAnchor)
        topNotificationViewConstraint?.isActive = true
        
        setNotificationView(hidden: true, animated: false, completion: nil)
    }
    
    func displayNotification(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let wSelf = self else { return }
            wSelf.scheduleNotification(with: message)
        }
    }
    
    internal func scheduleNotification(with message: String) {
        addNotificationView()
        messageQueue.append(message)
        
        if !notificationViewPresented {
            runMessageShowing()
        }
    }
    
    fileprivate func runMessageShowing() {
        if messageQueue.isEmpty {
            if notificationViewPresented {
                setNotificationView(hidden: true, animated: true, completion: nil)
            }
            return
        }
        
        notificationView?.setText(messageQueue.removeFirst())
        let nextMessageDispatch = { [weak self] in
            guard let wSelf = self else { return }
            
            let delay: TimeInterval = wSelf.messageQueue.isEmpty ? 2 : 1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                wSelf.runMessageShowing()
            }
        }
        
        if notificationViewPresented {
            nextMessageDispatch()
        } else {
            setNotificationView(hidden: false, animated: true, completion: nextMessageDispatch)
        }
    }
    
    fileprivate func setNotificationView(hidden: Bool, animated: Bool, completion: (() -> Void)?) {
        topNotificationViewConstraint?.constant = hidden ? -50 : 20
        let changes = { [weak self] in
            guard let wSelf = self else { return }
            wSelf.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear, .beginFromCurrentState], animations: changes) { (_) in completion?() }
        } else {
            changes()
            completion?()
        }
    }
}

