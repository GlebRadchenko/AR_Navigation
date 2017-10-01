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

protocol ARViewViewInput: class {
    var sceneView: ARSCNView! { get }
    func embedToContainer(viewController: UIViewController)
}

protocol ARViewViewOutput: class {
    func viewDidLoad()
    func viewDidAppear()
    func viewWillDisappear()
}

class ARViewController: UIViewController, View {
    static var storyboardName: String { return "AR" }
    
    @IBOutlet var sceneView: ARSCNView!
    
    weak var slideContainer: BottomSlideContainer!
    var slideContainerTopConstraint: NSLayoutConstraint!
    var containerState: SlideContainerState = .hidden
    
    var output: ARViewViewOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        setupBottomContainer()
        addGestureRecognizers()
        
        output.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        output.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        output.viewWillDisappear()
    }
    
    func addGestureRecognizers() {
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(tap:)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleContainerPan(pan:)))
        
        view.addGestureRecognizer(viewTap)
        slideContainer.addGestureRecognizer(pan)
    }
    
    @objc func handleViewTap(tap: UITapGestureRecognizer) {
        print(tap)
    }
    
    fileprivate var yTranslation: CGFloat = 0.0
    fileprivate var containerWasOpened: Bool = false
    fileprivate var previousStopFactor: CGFloat = 1
    
    @objc func handleContainerPan(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            switch containerState {
            case.presented:
                containerWasOpened = true
            default:
                containerWasOpened = false
            }
            
            containerState = .sliding
        case .changed:
            let yTranslation = pan.translation(in: view).y
            slideContainer(with: yTranslation, velocity: pan.velocity(in: view).y)
            self.yTranslation = yTranslation
        default:
            completeSliding(with: yTranslation)
        }
    }
}

extension ARViewController: ARViewViewInput {
    func embedToContainer(viewController: UIViewController) {
        slideContainer.embed(viewController: viewController, caller: self)
    }
}

enum SlideContainerState {
    case presented
    case hidden
    case sliding
}

//MARK: - Container Setuping and Managing
extension ARViewController {
    func setupBottomContainer() {
        let container = BottomSlideContainer(topViewHeight: 30)
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        container.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        container.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1 / .goldenSection, constant: 30).isActive = true
        slideContainerTopConstraint = container.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        slideContainerTopConstraint.isActive = true
        
        self.slideContainer = container
    }
    
    func slideContainer(with translation: CGFloat, velocity: CGFloat) {
        if velocity == 0 { return }
        let initialTranslation = containerWasOpened ? containerHeight() : 30
        var translation = translation
        
        if containerWasOpened && translation < 0 {
            translation = translation * previousStopFactor
            previousStopFactor *= 0.9
        } else if !containerWasOpened && translation < -containerHeight() {
            translation = translation * previousStopFactor
            previousStopFactor *= 0.9
        }
        
        moveContainer(yTranslation: translation - initialTranslation)
    }
    
    func moveContainer(yTranslation: CGFloat) {
        slideContainerTopConstraint.constant = yTranslation
    }
    
    func completeSliding(with yTranslation: CGFloat) {
        previousStopFactor = 1
        
        if containerWasOpened {
            if yTranslation > 30 {
                toggleContainer(open: false, animated: true)
            } else {
                toggleContainer(open: true, animated: true)
            }
        } else {
            if yTranslation < -30 {
                toggleContainer(open: true, animated: true)
            } else {
                toggleContainer(open: false, animated: true)
            }
        }
    }
    
    func toggleContainer(open: Bool, animated: Bool) {
        let constant = open ? -containerHeight() : -30
        moveContainer(yTranslation: constant)
        containerState = open ? .presented : .hidden
        
        if animated {
            var options: UIViewAnimationOptions = [.beginFromCurrentState]
            open ? options.formUnion(.curveEaseIn) : options.formUnion(.curveEaseOut)
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           options: options,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    func containerHeight() -> CGFloat {
        return view.bounds.width / .goldenSection + 30
    }
}


