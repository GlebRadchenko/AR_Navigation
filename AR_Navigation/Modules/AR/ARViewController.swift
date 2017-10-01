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
    
    func endEditing()
    func embedToContainer(viewController: UIViewController)
    func toggleContainer(open: Bool, animated: Bool)
    func updateViews(for keyboardFrame: CGRect?, duration: TimeInterval)
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(tap:)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleContainerPan(pan:)))
        
        slideContainer.topView.addGestureRecognizer(tap)
        slideContainer.addGestureRecognizer(pan)
    }
    
    @objc func handleViewTap(tap: UITapGestureRecognizer) {
        view.endEditing(true)
        
        switch containerState {
        case .presented: toggleContainer(open: false, animated: true)
        case .hidden: toggleContainer(open: true, animated: true)
        default: break
        }
    }
    
    fileprivate var yTranslation: CGFloat = 0.0
    fileprivate var containerWasOpened: Bool = false
    fileprivate var previousStopFactor: CGFloat = 1
    fileprivate var keyboardHeight: CGFloat = 0
    
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
            view.endEditing(true)
            completeSliding(with: yTranslation)
        }
    }
}

extension ARViewController: ARViewViewInput {
    func endEditing() {
        view.endEditing(true)
    }
    
    func updateViews(for keyboardFrame: CGRect?, duration: TimeInterval) {
        let initialTranslation = containerState == .presented ? containerHeight() : BottomSlideContainer.topViewHeight
        
        if let keyboardFrame = keyboardFrame {
            keyboardHeight = keyboardFrame.height
            slideContainerTopConstraint.constant = -(initialTranslation + keyboardFrame.height)
        } else {
            keyboardHeight = 0
            slideContainerTopConstraint.constant = -initialTranslation
        }
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
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
        let container = BottomSlideContainer(topViewHeight: BottomSlideContainer.topViewHeight)
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        container.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        container.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1 / .goldenSection, constant: BottomSlideContainer.topViewHeight).isActive = true
        slideContainerTopConstraint = container.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -BottomSlideContainer.topViewHeight)
        slideContainerTopConstraint.isActive = true
        
        self.slideContainer = container
    }
    
    func slideContainer(with translation: CGFloat, velocity: CGFloat) {
        if velocity == 0 { return }
        let initialTranslation = (containerWasOpened ? containerHeight() : BottomSlideContainer.topViewHeight) + keyboardHeight
        var translation = translation
        
        if containerWasOpened && translation < 0 {
            translation = translation * previousStopFactor
            previousStopFactor *= 0.99
        } else if !containerWasOpened && translation < -containerHeight() {
            translation = translation * previousStopFactor
            previousStopFactor *= 0.99
        }
        
        moveContainer(yTranslation: translation - initialTranslation)
    }
    
    func moveContainer(yTranslation: CGFloat) {
        slideContainerTopConstraint.constant = yTranslation
    }
    
    func completeSliding(with yTranslation: CGFloat) {
        previousStopFactor = 1
        
        if containerWasOpened {
            if yTranslation > BottomSlideContainer.topViewHeight {
                toggleContainer(open: false, animated: true)
            } else {
                toggleContainer(open: true, animated: true)
            }
        } else {
            if yTranslation < -BottomSlideContainer.topViewHeight {
                toggleContainer(open: true, animated: true)
            } else {
                toggleContainer(open: false, animated: true)
            }
        }
    }
    
    func toggleContainer(open: Bool, animated: Bool) {
        let constant = (open ? containerHeight() : BottomSlideContainer.topViewHeight) + keyboardHeight
        moveContainer(yTranslation: -constant)
        containerState = open ? .presented : .hidden
        
        if animated {
            var options: UIViewAnimationOptions = [.beginFromCurrentState]
            open ? options.formUnion(.curveEaseIn) : options.formUnion(.curveEaseOut)
            
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: options,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    func containerHeight() -> CGFloat {
        return view.bounds.width / .goldenSection + BottomSlideContainer.topViewHeight
    }
}


