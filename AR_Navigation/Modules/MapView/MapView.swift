//
//  MapViewController.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewViewInput: class {
    var mapView: MKMapView! { get }
    
    func endEditing()
    func type(for searchBar: UISearchBar) -> SearchBarType
    
    func updateViews(for state: MapState, animated: Bool)
    func updateActions(with items: [MapActionDisplayable])
    
    func showActivityIndicator()
    func hideActivityIndicator()
}

protocol MapViewViewOutput: class, UISearchBarDelegate {
    func viewDidLoad()
    
    func handleActionSelection(at index: Int)
    func handleGoAction()
    func handleLocationAction()
}

class MapViewController: UIViewController, View {
    typealias Presenter = MapViewViewOutput
    
    static var storyboardName: String { return "MapView" }
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var visualEffectTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var visualEffectViewContainer: UIVisualEffectView!
    @IBOutlet weak var stackViewContainer: UIStackView!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var firstContainerView: UIView!
    @IBOutlet weak var firstSearchBar: UISearchBar!
    
    @IBOutlet weak var secondContainerView: UIView!
    @IBOutlet weak var secondSearchBar: UISearchBar!
    
    @IBOutlet weak var actionsCollectionView: UICollectionView!
    
    var actions: [MapActionDisplayable] = []
    
    weak var output: MapViewViewOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        output.viewDidLoad()
    }
    
    func configureViews() {
        configureTextFields()
        configureCollectionView()
        configureMapView()
    }
    
    func configureTextFields() {
        firstSearchBar.delegate = output
        secondSearchBar.delegate = output
        
       // firstTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
       // secondTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func configureCollectionView() {
        actionsCollectionView.backgroundColor = .clear
        actionsCollectionView.register(MapActionCollectionViewCell.self)
    }
    
    func configureMapView() {
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        mapView.showsPointsOfInterest = true
        mapView.showsUserLocation = true
    }
    
    @IBAction func goButtonTouched(_ sender: UIButton) {
        output.handleGoAction()
    }
    
    @IBAction func locationButtonTouched(_ sender: UIButton) {
        output.handleLocationAction()
    }
}

enum SearchBarType {
    case source
    case destination
    case unknown
}

extension MapViewController: MapViewViewInput {
    
    func endEditing() {
        view.endEditing(true)
    }
    
    func type(for searchBar: UISearchBar) -> SearchBarType {
        if searchBar == firstSearchBar {
            return .source
        }
        
        if searchBar == secondSearchBar {
            return .destination
        }
        
        return .unknown
    }
    
    func updateViews(for state: MapState, animated: Bool) {
        visualEffectTopConstraint.constant = state.shouldDisplaySearchPanel
            ? 0
            : -BottomSlideContainer.topViewHeight
        
        secondContainerView.isHidden = !state.bothTextFieldsAreDisplayed
        
        firstSearchBar.text = ""
        firstSearchBar.placeholder = state.firstPlaceholder
        
        secondSearchBar.text = ""
        secondSearchBar.placeholder = state.secondPlaceholder
        
        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options:[.curveEaseInOut, .beginFromCurrentState],
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    func updateActions(with items: [MapActionDisplayable]) {
        actions = items
        actionsCollectionView.reloadData()
    }
    
    func showActivityIndicator() {
        activityView.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityView.stopAnimating()
    }
}

extension MapViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        output.handleActionSelection(at: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = actions[indexPath.item]
        let width = MapActionCollectionViewCell.estimatedWidth(for: item.stringValue, height: collectionView.bounds.height)
        
        return CGSize(width: width, height: collectionView.bounds.height)
    }
}

extension MapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MapActionCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        
        cell.configure(with: actions[indexPath.item])
        
        return cell
    }
}

