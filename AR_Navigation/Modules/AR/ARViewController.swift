//
//  ARViewController.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 9/24/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    weak var slideContainer: BottomSlideContainer!
    var slideContainerTopConstraint: NSLayoutConstraint!
    
    var mapModule: Module!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        setupBottomContainer()
        loadMapModule()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
}

extension ARViewController {
    func loadMapModule() {
        do {
            mapModule = try MapViewRouter.module()
            slideContainer.embed(viewController: mapModule.view, caller: self)
        } catch {
            debugPrint(error)
        }
    }
    
    func setupBottomContainer() {
        let container = BottomSlideContainer(topViewHeight: 30)
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        container.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        slideContainerTopConstraint = container.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1 / .goldenSection, constant: 30)
        slideContainerTopConstraint.isActive = true
        container.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -containerHeight()).isActive = true
        
        self.slideContainer = container
    }
    
    func containerHeight() -> CGFloat {
        return view.bounds.width / .goldenSection + 30
    }
}


