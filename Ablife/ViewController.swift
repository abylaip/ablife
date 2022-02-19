//
//  ViewController.swift
//  Ablife
//
//  Created by Azamat Mukhamejanov on 12/6/17.
//  Copyright © 2017 Azamat Mukhamejanov. All rights reserved.
//

import UIKit
import CoreMotion
import UserNotifications
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate{
    let locationManager = CLLocationManager()
    var motionManager = CMMotionManager()
    var lat = Double()
    var long = Double()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lat = 0
        let timer = self.setInterval(60){
            guard let url = URL(string: "http://komek.herokuapp.com/iAmOk/3")
                else {
                    return
            }
            let session = URLSession.shared
            session.dataTask(with:url) {
                (data, response, error) in
                if let response = response{
                    print(response)
                }
                if let data = data {
                    print(data)
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print(json)
                    } catch {
                        print (error)
                    }
                }
                }.resume()
        }
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
                if let motion = motion {
                    var x = motion.userAcceleration.x
                    var y = motion.userAcceleration.y
                    var z = motion.userAcceleration.z
                    
                    // Truncate to 2 significant digits
                    x = round(100 * x) / 100
                    y = round(100 * y) / 100
                    z = round(100 * z) / 100
                    
                    // Ditch the -0s because I don't like how they look being printed
                    if x.isZero && x.sign == .minus {
                        x = 0.0
                    }
                    
                    if y.isZero && y.sign == .minus {
                        y = 0.0
                    }
                    
                    if z.isZero && z.sign == .minus {
                        z = 0.0
                    }
                     if x > 0.4 || y > 0.4 || z > 0.4 {
                        
                        let content = UNMutableNotificationContent()
                        content.body = "ARE YOU OK?"
                        content.badge = 1
                        
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                        let request = UNNotificationRequest(identifier: "timeDown" , content: content, trigger: trigger)
                        
                        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                       
                        
                        guard let url = URL(string: "http://komek.herokuapp.com/help/3?lat=\(self.lat)&long=\(self.long)")
                            else {
                                return
                        }
                        let session = URLSession.shared
                        session.dataTask(with:url) {
                            (data, response, error) in
                            if let response = response{
                                print(response)
                            }
                            if let data = data {
                                print(data)
                                do {
                                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                                    print(json)
                                } catch {
                                    print (error)
                                }
                            }
                            }.resume()
                        
                    }
                    }
                
                
            }
        // For use when the app is open & in the background
        locationManager.requestAlwaysAuthorization()
        
        // For use when the app is open
        locationManager.requestWhenInUseAuthorization()
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
        }
  
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // For use when the app is open & in the background
        locationManager.requestAlwaysAuthorization()
        
        // For use when the app is open
        locationManager.requestWhenInUseAuthorization()
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
        }
    }
    
    func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {
        return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: true)
    }
    func setInterval(_ interval:TimeInterval, block:@escaping ()->Void) -> Timer {
        return Timer.scheduledTimer(timeInterval: interval, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: true)
    }
    
    // Print out the location to the console
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(location.coordinate)
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            lat = locValue.latitude
            long = locValue.longitude
        }
    }
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "We need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    }

    
   


