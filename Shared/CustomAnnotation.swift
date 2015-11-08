//
//  CustomAnnotation.swift
//  MapCallouts
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/8.
//
//
/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The custom MKAnnotation object representing a generic location, hosting a title and image.
 */

import Foundation
import MapKit

/// annotation for the Tea Garden
@objc(CustomAnnotation)
class CustomAnnotation: NSObject, MKAnnotation {
    
    var place: String?
    var imageName: String?
    
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    class func createViewAnnotationForMapView(mapView: MKMapView, annotation: MKAnnotation) -> MKAnnotationView {
        var returnedAnnotationView =
        mapView.dequeueReusableAnnotationViewWithIdentifier(String(CustomAnnotation.self)) as? CustomAnnotationView
        if returnedAnnotationView == nil {
            returnedAnnotationView =
                CustomAnnotationView(annotation: annotation, reuseIdentifier: String(CustomAnnotation.self))
        }
        
        return returnedAnnotationView!
    }
    
}