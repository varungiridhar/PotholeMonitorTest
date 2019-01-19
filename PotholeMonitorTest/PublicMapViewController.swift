//
//  PublicMapViewController.swift
//  PotholeMonitorTest
//
//  Created by Admin on 19/01/19.
//  Copyright © 2019 GG. All rights reserved.
//

import UIKit
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
    
    var allPotholeLocations : [CLLocationCoordinate2D] = []
    var allPotholeDepth : [Double] = []
    let path = GMSMutablePath()
    
    
    @IBOutlet weak var viewForPGMaps: UIView!
    var ref : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //GMS
        var cameraPosition = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 18)
        mapView = GMSMapView.map(withFrame: self.viewForPGMaps.frame, camera: cameraPosition)
        self.view.addSubview(mapView)
        //LOCATION
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        getData()
    }
    
    func getData(){
        ref = Database.database().reference().child("data")
        
        
        ref.observe(DataEventType.value) { (snapshot) in
            var noOfLoc = snapshot.childrenCount - 1
            for i in 0...noOfLoc{
                self.ref.child(String(i)).child("latitude").observe(DataEventType.value) { (latsnapshot) in
                    self.ref.child(String(i)).child("longitude").observe(DataEventType.value) { (longsnapshot) in
                        self.ref.child(String(i)).child("potholeDepth").observe(DataEventType.value) { (depthsnapshot) in
                            
                            self.setMap(lat: latsnapshot, long: longsnapshot, potholeDepth: depthsnapshot, index : i, upperIndex : noOfLoc)
                        }
                    }
                }
            }
        }
    }
    
    
    func setMap(lat : DataSnapshot, long : DataSnapshot, potholeDepth : DataSnapshot, index : UInt, upperIndex : UInt){
        var latitude = lat.value
        var longitude = long.value
        var pD = potholeDepth.value
        var potholeLocation = CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
        
        allPotholeLocations.append(potholeLocation)
        allPotholeDepth.append(pD as! Double)
        var potholeLocationMarker  = GMSMarker(position:potholeLocation )
        potholeLocationMarker.icon = UIImage.init(named: "potholeIcon")
        potholeLocationMarker.map = mapView
        mapView.animate(toLocation: potholeLocation)
        
        if(index == Int(upperIndex)){
            var totalPotholeDepth = 0.0
            
            for i in 0...upperIndex{
                path.add(allPotholeLocations[Int(i)])
                totalPotholeDepth = (totalPotholeDepth + allPotholeDepth[Int(i)])

                //MACHINE LEARNING PART
                //OOOOOOF
                
                
            }
            var avgPotholeDepth : Double = totalPotholeDepth/Double(allPotholeDepth.endIndex)
            
            let polyline = GMSPolyline(path: path)
            if (avgPotholeDepth < -2){
                polyline.strokeColor = UIColor.red
                
            }else{
                if (avgPotholeDepth < -1.5){
                    polyline.strokeColor = UIColor.yellow
                    
                }else{
                    
                    polyline.strokeColor = UIColor.green
                    
                }
            }
            
            mapView.animate(toZoom: 17)
            polyline.strokeWidth = 8.0
            polyline.map = mapView
        }

    }
}





