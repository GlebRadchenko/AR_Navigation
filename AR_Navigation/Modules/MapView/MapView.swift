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

protocol MapViewViewInput: PopoverDisplayer {
    var mapView: MKMapView! { get }
    
    func endEditing()
    func type(for searchBar: UISearchBar) -> SearchBarType
    
    func addOrUpdateAnnotation(for container: LocationContainer, decoratorBlock: @escaping (_ annotation: MapAnnotation) -> Void)
    func removeAnnotation(for container: LocationContainer)
    func clearAllPins()
    
    func updateViews(for state: MapAction, animated: Bool)
    func updateActions(with items: [MapActionDisplayable])
    func updateUserHeading(_ heading: CLHeading)
    
    func showActivityIndicator()
    func hideActivityIndicator()
}

protocol MapViewViewOutput: class, UISearchBarDelegate {
    func viewDidLoad()
    
    func handleActionSelection(at index: Int)
    func handleGoAction()
    func handleLocationAction()
    
    func handleDragAction(for container: LocationContainer)
    func handleTapAction(for location: CLLocationCoordinate2D)
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
    
    weak var headingImageView: UIImageView!
    
    var actions: [MapActionDisplayable] = []
    
    weak var output: MapViewViewOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        output.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(tap:)))
        mapView.addGestureRecognizer(tap)
    }
    
    func configureViews() {
        configureTextFields()
        configureCollectionView()
        configureMapView()
    }
    
    func configureTextFields() {
        firstSearchBar.delegate = output
        secondSearchBar.delegate = output
    }
    
    func configureCollectionView() {
        actionsCollectionView.backgroundColor = .clear
        actionsCollectionView.register(MapActionCollectionViewCell.self)
    }
    
    func configureMapView() {
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        mapView.showsPointsOfInterest = true
        mapView.userTrackingMode = .followWithHeading
    }
    
    @objc func handleTap(tap: UITapGestureRecognizer) {
        let tapLocation = tap.location(in: mapView)
        let coordinate = mapView.convert(tapLocation, toCoordinateFrom: view)
        output.handleTapAction(for: coordinate)
    }
    
    @IBAction func goButtonTouched(_ sender: UIButton) {
        output.handleGoAction()
    }
    
    @IBAction func locationButtonTouched(_ sender: UIButton) {
        output.handleLocationAction()
    }
    
    func addHeadingArrow(to view: MKAnnotationView) {
        guard headingImageView == nil else { return }
        let bounds = view.bounds
        
        let arrow = #imageLiteral(resourceName: "icon_heading_arrow").withRenderingMode(.alwaysTemplate)
        let arrowSize: CGFloat = 15
        
        let imageView = UIImageView()
        imageView.tintColor = .darkGray
        imageView.contentMode = .scaleAspectFit
        imageView.image = arrow
        
        imageView.frame = CGRect(x: (bounds.size.width - arrowSize) / 2,
                                 y: (bounds.size.height - arrowSize) / 2,
                                 width: arrowSize,
                                 height: arrowSize)
        
        view.addSubview(imageView)
        headingImageView = imageView
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
    
    func clearAllPins() {
        mapView.removeAnnotations(mapView.annotations)
    }
    
    func updateViews(for state: MapAction, animated: Bool) {
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
    
    func addOrUpdateAnnotation(for container: LocationContainer, decoratorBlock: @escaping (_ annotation: MapAnnotation) -> Void) {
        removeAnnotation(for: container)
        let newAnnotation = MapAnnotation(container: container)
        decoratorBlock(newAnnotation)
        mapView.addAnnotation(newAnnotation)
    }
    
    func removeAnnotation(for container: LocationContainer) {
        guard let removing = mapView.annotations.first(where: { (annotation) -> Bool in
            guard let mapAnnotation = annotation as? MapAnnotation else { return false }
            return mapAnnotation.locationContainer.id == container.id
        }) else { return }
        
        mapView.removeAnnotation(removing)
    }
    
    func updateActions(with items: [MapActionDisplayable]) {
        actions = items
        actionsCollectionView.reloadData()
    }
    
    
    func updateUserHeading(_ heading: CLHeading) {
        guard let headingImageView = headingImageView else { return }
        guard heading.headingAccuracy >= 0 else { return }
        
        let degreesAngle = heading.trueHeading > 0 ? heading.trueHeading : heading.magneticHeading
        let radAngle = CGFloat(degreesAngle / 180 * .pi)
        
        let rotation = CGAffineTransform(rotationAngle: radAngle)
        
        let x: CGFloat = 0
        let y: CGFloat = -11
        
        let tX = x * cos(radAngle) - y * sin(radAngle)
        let tY = x * sin(radAngle) + y * cos(radAngle)
        
        let translation = CGAffineTransform(translationX: tX, y: tY)
        
        let transform = rotation.concatenating(translation)
        
        headingImageView.transform = transform
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

extension MapViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let mapAnnotation = annotation as? MapAnnotation else { return nil }
        
        let annotationView: MKMarkerAnnotationView = mapView.dequeueReusableAnnotationView() ?? MKMarkerAnnotationView(annotation: mapAnnotation)

        annotationView.animatesWhenAdded = true
        annotationView.markerTintColor = MKPinAnnotationView.purplePinColor()
        annotationView.isDraggable = true
        
        return annotationView
    }
    
    public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        guard let userLocationAnnotation = views.first(where: { $0.annotation is MKUserLocation }) else { return }
        addHeadingArrow(to: userLocationAnnotation)
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    }
    
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
    }
    
    public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
    }
    
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        guard let annotation = view.annotation as? MapAnnotation else { return }
        switch newState {
        case .ending, .canceling:
            annotation.locationContainer.coordinate = annotation.coordinate
            output?.handleDragAction(for: annotation.locationContainer)
        default: break
        }
    }
}

