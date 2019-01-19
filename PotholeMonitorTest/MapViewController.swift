//
//  MapViewController.swift
//  PotholeMonitorTest
//
//  Created by GG on 13/01/19.
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
class MapViewController: UIViewController, CLLocationManagerDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var potholeLabel: UILabel!
    var motionManager = CMMotionManager()
    var player : AVAudioPlayer = AVAudioPlayer()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var currentLocationMarker = GMSMarker()
    var allPotholeLocations : [CLLocationCoordinate2D] = []
    var allPotholeDepth : [Double] = []
    let path = GMSMutablePath()
    var ref : DatabaseReference!
    
    @IBOutlet weak var potholeAlert: UIImageView!
    
    
    
    @IBOutlet weak var viewForGMaps: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //GMS
        var cameraPosition = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 20)
        mapView = GMSMapView.map(withFrame: self.viewForGMaps.frame, camera: cameraPosition)
        self.view.addSubview(mapView)
        //LOCATION
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        //audio playing
        let audioPlayer = Bundle.main.path(forResource: "notification", ofType: "mp3")
        do{
            try player = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPlayer!) as URL)
        }
        catch{
            //error
        }
        

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let myLocation = CLLocationCoordinate2D(latitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude))
        let camera = GMSCameraPosition.camera(withTarget: myLocation, zoom: 22.0)
        self.mapView.animate(to: camera)
        
        
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if let acData = data{
                if acData.acceleration.y < -1.2{
                    
                    
                    
                    
                    
                    
                    self.potholeLabel.text = String(acData.acceleration.y)
                    var potholeDepth : Double = acData.acceleration.y
                    self.makePotholeMarker(potholeLocation: myLocation)
                    self.allPotholeLocations.append(myLocation)
                    self.allPotholeDepth.append(potholeDepth)
                    
                    
                }
            
            }
            
        }
        
        
        
        makeCurrentLocationMarker(currentLocation: myLocation)
        
        
        
        
    }
    func makeCurrentLocationMarker(currentLocation : CLLocationCoordinate2D){
        currentLocationMarker.map = nil
        currentLocationMarker = GMSMarker(position: currentLocation)
        currentLocationMarker.icon = UIImage.init(named: "icon")
        currentLocationMarker.map = mapView
        
        
    }
    
    func makePotholeMarker(potholeLocation : CLLocationCoordinate2D){
        var potholeLocationMarker  = GMSMarker(position: potholeLocation)
        potholeLocationMarker.icon = UIImage.init(named: "potholeIcon")
        potholeLocationMarker.map = mapView
        player.play()
        
    }
    
    @IBAction func doneAction(_ sender: Any) {
        
        ref = Database.database().reference().child("data")

        let upperIndex = allPotholeDepth.endIndex - 1
        var totalPotholeDepth = 0.0
        for i in 0...upperIndex{
            totalPotholeDepth = (totalPotholeDepth + allPotholeDepth[i])
            path.add(allPotholeLocations[i])
            
            ref.child(String(i)).child("locationLatitude").setValue(allPotholeLocations[i].latitude)
            ref.child(String(i)).child("locationLongitude").setValue(allPotholeLocations[i].longitude)
            ref.child(String(i)).child("potholeDepth").setValue(allPotholeDepth[i])

        }
        
        var avgPotholeDepth : Double = totalPotholeDepth/Double(allPotholeDepth.endIndex)
        potholeLabel.text = String(avgPotholeDepth)
        


        let polyline = GMSPolyline(path: path)
        if (avgPotholeDepth < -2.8){
            polyline.strokeColor = UIColor.red
            
        }else{
        if (avgPotholeDepth < -2.3){
            polyline.strokeColor = UIColor.yellow
            
        }else{
        
            polyline.strokeColor = UIColor.green
            
        }
        }

        locationManager.stopUpdatingLocation()
        mapView.animate(toLocation: allPotholeLocations[upperIndex])
        mapView.animate(toZoom: 18)
        polyline.strokeWidth = 10.0
        polyline.map = mapView
        
        //FIREBASE CODE
        
        
        allPotholeDepth.removeAll()
        allPotholeLocations.removeAll()

    }
    

}
