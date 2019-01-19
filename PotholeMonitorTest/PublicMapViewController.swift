//
//  PublicMapViewController.swift
//  PotholeMonitorTest
//
//  Created by Admin on 19/01/19.
//  Copyright © 2019 GG. All rights reserved.
//


import UIKit
import CoreMotion
import CoreLocation
import MapKit
import GoogleMaps
import GooglePlaces
import Firebase
import AVFoundation
class PublicMapViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var mapView : GMSMapView!
    
    @IBOutlet weak var viewForPGMaps: UIView!
    var ref : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //GMS
        var cameraPosition = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 20)
        mapView = GMSMapView.map(withFrame: self.viewForPGMaps.frame, camera: cameraPosition)
        self.view.addSubview(mapView)
        //LOCATION
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        getData()
    }
    
    func getData(){
        ref = Database.database().reference().child("data").child("0")
        ref.child("locationLatitude").observe(DataEventType.value) { (latsnapshot) in
            self.ref.child("locationLongitude").observe(DataEventType.value) { (longsnapshot) in
                self.ref.child("potholeDepth").observe(DataEventType.value) { (depthsnapshot) in
                    
                }
            }
        }
    }

}
    


 
