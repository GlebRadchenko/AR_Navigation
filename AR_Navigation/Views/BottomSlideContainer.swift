//
//  BottomSlideContainer.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit
class BottomSlideContainer: UIView {
    var topViewHeight: CGFloat
    
    weak var containerView: UIView!
    weak var embededViewController: UIViewController?
    
    init(topViewHeight: CGFloat) {
        self.topViewHeight = topViewHeight
        super.init(frame: .zero)
        backgroundColor = .clear
        initialLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        topViewHeight = 20
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        initialLayout()
    }
    
    func embed(viewController: UIViewController, caller: UIViewController?) {
        embededViewController?.willMove(toParentViewController: nil)
        embededViewController?.view.removeFromSuperview()
        embededViewController?.removeFromParentViewController()
        
        guard let embedingView = viewController.view else { return }
        
        caller?.addChildViewController(viewController)
        containerView.embed(other: embedingView)
        viewController.didMove(toParentViewController: caller)
    }
}

extension BottomSlideContainer {
    fileprivate func initialLayout() {
        let topView = UIView()
        topView.backgroundColor = .clear
        topView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topView)
        
        [topView.leadingAnchor.constraint(equalTo: leadingAnchor),
         topView.trailingAnchor.constraint(equalTo: trailingAnchor),
         topView.topAnchor.constraint(equalTo: topAnchor),
         topView.heightAnchor.constraint(equalToConstant: topViewHeight)].forEach { $0.isActive = true }
        
        let accessoryView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        accessoryView.layer.cornerRadius = 3
        accessoryView.clipsToBounds = true
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(accessoryView)
        
        [accessoryView.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
         accessoryView.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
         accessoryView.heightAnchor.constraint(equalToConstant: 6),
         accessoryView.widthAnchor.constraint(equalToConstant: 30)].forEach { $0.isActive = true }
        
        let container = UIView()
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        container.clipsToBounds = true
        addSubview(container)
        
        [container.leadingAnchor.constraint(equalTo: leadingAnchor),
         container.trailingAnchor.constraint(equalTo: trailingAnchor),
         container.topAnchor.constraint(equalTo: topView.bottomAnchor),
         container.bottomAnchor.constraint(equalTo: bottomAnchor)].forEach { $0.isActive = true }
        
        containerView = container
    }
}

