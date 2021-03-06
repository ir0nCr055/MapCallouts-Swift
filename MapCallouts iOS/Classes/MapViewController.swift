//
//  MapViewController.swift
//  MapCallouts
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/8.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The primary view controller containing the MKMapView, adding and removing both MKPinAnnotationViews through its toolbar.
 */

import UIKit
import MapKit

@objc(MapViewController)
class MapViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet private weak var mapView: MKMapView!
    private var mapAnnotations: [MKAnnotation] = []
    
    
    //MARK: -
    
    private func gotoDefaultLocation() {
        // start off by default in San Francisco
        var newRegion = MKCoordinateRegion()
        newRegion.center.latitude = 37.786996
        newRegion.center.longitude = -122.440100
        newRegion.span.latitudeDelta = 0.2
        newRegion.span.longitudeDelta = 0.2
        
        self.mapView.setRegion(newRegion, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // restore the nav bar to translucent
        self.navigationController!.navigationBar.barStyle = UIBarStyle.black
        self.navigationController!.navigationBar.isTranslucent = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a custom navigation bar button and set it to always says "Back"
        let temporaryBarButtonItem = UIBarButtonItem()
        temporaryBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem
        
        // create out annotations array (in this example only 3)
        self.mapAnnotations = []
        
        // annotation for the City of San Francisco
        let sfAnnotation = SFAnnotation()
        self.mapAnnotations.append(sfAnnotation)
        
        // annotation for Golden Gate Bridge
        let bridgeAnnotation = BridgeAnnotation()
        self.mapAnnotations.append(bridgeAnnotation)
        
        // annotation for Fisherman's Wharf
        let wharfAnnotation = WharfAnnotation()
        self.mapAnnotations.append(wharfAnnotation)
        
        // annotation for Japanese Tea Garden
        let item = CustomAnnotation()
        item.place = "Tea Garden"
        item.imageName = "teagarden"
        item.coordinate = CLLocationCoordinate2DMake(37.770, -122.4709)
        
        self.mapAnnotations.append(item)
        
        self.allAction(self)  // initially show all annotations
    }
    
    
    //MARK: - Button Actions
    
    private func gotoByAnnotationClass(_ annotationClass: AnyClass) {
        // user tapped "City" button in the bottom toolbar
        for annotation in self.mapAnnotations {
            if annotation.isKind(of: annotationClass) {
                // remove any annotations that exist
                self.mapView.removeAnnotations(self.mapView.annotations)
                // add just the city annotation
                self.mapView.addAnnotation(annotation)
                
                self.gotoDefaultLocation()
            }
        }
    }
    
    @IBAction func cityAction(_: Any) {
        self.gotoByAnnotationClass(SFAnnotation.self)
    }
    
    @IBAction func bridgeAction(_: Any) {
        // user tapped "Bridge" button in the bottom toolbar
        self.gotoByAnnotationClass(BridgeAnnotation.self)
    }
    
    @IBAction func wharfAction(_: Any) {
        // user tapped "Wharf" button in the bottom toolbar
        self.gotoByAnnotationClass(WharfAnnotation.self)
    }
    
    @IBAction func teaGardenAction(_: Any) {
        // user tapped "Tea Gardon" button in the bottom toolbar
        self.gotoByAnnotationClass(CustomAnnotation.self)
    }
    
    @IBAction func allAction(_: Any) {
        // user tapped "All" button in the bottom toolbar
        
        // remove any annotations that exist
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        // add all the custom annotations
        self.mapView.addAnnotations(self.mapAnnotations)
        
        self.gotoDefaultLocation()
    }
    
    // dismissing the bridge detail view controller
    @objc func doneAction(_: Any) {
        self.dismiss(animated: true) {
            //.. done
        }
    }
    
    // For iPhone/compact:
    // present/wrap the detail view controller in a navigation controller,
    // If this method is not implemented, or returns nil, then the originally presented view controller is used
    //
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navController = UINavigationController(rootViewController: controller.presentedViewController)
        
        // for the detail view controller we want a black style nav bar
        navController.navigationBar.barStyle = UIBarStyle.black
        
        let presentedViewController = controller.presentedViewController
        presentedViewController.navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneAction(_:)))
        
        return navController
    }
    
    @objc func buttonAction(_ button: UIButton) {
        NSLog("clicked Golden Gate Bridge annotation")
        
        let detailViewController = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController")
        detailViewController.edgesForExtendedLayout = UIRectEdge()
        detailViewController.modalPresentationStyle = .popover
        let presentationController = detailViewController.popoverPresentationController
        
        // display popover from the UIButton (sender) as the anchor
        presentationController?.sourceRect = button.frame
        presentationController?.sourceView = button.superview
        
        presentationController?.permittedArrowDirections = .any
        
        // not required, but useful for presenting "contentVC" in a compact screen so that it
        // can be dismissed as a full screen view controller)
        //
        presentationController?.delegate = self
        
        self.present(detailViewController, animated: true) {
            //.. done
        }
    }
    
    
    //MARK: - MKMapViewDelegate
    
    // user tapped the disclosure button in the bridge callout
    //
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // here we illustrate how to detect which annotation type was clicked on for its callout
        let annotation = view.annotation!
        if annotation is BridgeAnnotation {
            // user tapped the Golden Gate Bridge annotation
            //
            // note, we handle the accessory button press in "buttonAction"
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var returnedAnnotationView: MKAnnotationView? = nil
        
        // in case it's the user location, we already have an annotation, so just return nil
        if !(annotation is MKUserLocation) {
            // handle our custom annotations
            //
            if annotation is BridgeAnnotation { // for Golden Gate Bridge
                returnedAnnotationView = BridgeAnnotation.createViewAnnotationForMapView(self.mapView, annotation: annotation)
                
                // add a detail disclosure button to the callout which will open a new view controller page or a popover
                //
                // note: when the detail disclosure button is tapped, we respond to it via:
                //       calloutAccessoryControlTapped delegate method
                //
                // by using "calloutAccessoryControlTapped", it's a convenient way to find out which annotation was tapped
                //
                let rightButton = UIButton(type: .detailDisclosure)
                rightButton.addTarget(self, action: #selector(self.buttonAction(_:)), for: .touchUpInside)
                returnedAnnotationView!.rightCalloutAccessoryView = rightButton
            } else if annotation is WharfAnnotation { // for Fisherman's Wharf
                returnedAnnotationView = WharfAnnotation.createViewAnnotationForMapView(self.mapView,  annotation: annotation)
                
                // provide an image view to use as the accessory view's detail view.
                let imageView = UIImageView(image: UIImage(named: "wharf"))
                returnedAnnotationView!.detailCalloutAccessoryView = imageView;
            } else if annotation is SFAnnotation {   // for City of San Francisco
                returnedAnnotationView = SFAnnotation.createViewAnnotationForMapView(self.mapView, annotation: annotation)
                
                // provide the annotation view's image
                returnedAnnotationView!.image = UIImage(named: "flag")
                
                // provide the left image icon for the annotation
                let sfIconView = UIImageView(image: UIImage(named: "SFIcon"))
                returnedAnnotationView!.leftCalloutAccessoryView = sfIconView
            } else if annotation is CustomAnnotation {  // for Japanese Tea Garden
                returnedAnnotationView = CustomAnnotation.createViewAnnotationForMapView(self.mapView, annotation: annotation)
            }
        }
        
        return returnedAnnotationView
    }
    
}
