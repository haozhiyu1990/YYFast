//
//  YYLocationManager.swift
//  YYFastDemo
//
//  Created by haozhiyu on 2019/1/30.
//  Copyright © 2019 haozhiyu. All rights reserved.
//

import UIKit
import CoreLocation

open class YYLocationManager: NSObject {
    private let clmanager = CLLocationManager()
    private var currentLocation: CLLocation?
    private var callBack: (()->())?
    
    public static let shared = YYLocationManager()
    public var latitude: Double?
    public var longitude: Double?
    public var address: String?

    private override init() {
        super.init()
        clmanager.delegate = self
        clmanager.desiredAccuracy = kCLLocationAccuracyBest
        clmanager.requestAlwaysAuthorization()
        clmanager.requestWhenInUseAuthorization()
    }
    
    
    public func startLocation(_ complete: (()->())? = nil) {
        callBack = complete
        clmanager.startUpdatingLocation()
    }
    
    private func LonLatToCity() {
        let clgeocoder = CLGeocoder()
        clgeocoder.reverseGeocodeLocation(currentLocation!) { [weak self] (placemarks, _) in
            if let marks = placemarks {
                if let mark = marks.first {
                    let country = mark.country ?? ""
                    let administrativeArea = mark.administrativeArea ?? ""
                    let locality = mark.locality ?? ""
                    let subLocality = mark.subLocality ?? ""
                    let thoroughfare = mark.thoroughfare ?? ""
                    let subThoroughfare = mark.subThoroughfare ?? ""
                    
                    self?.address = country+administrativeArea+locality+subLocality+thoroughfare+subThoroughfare
                }
            } 
            if let back = self?.callBack {
                back()
                self?.callBack = nil
            }
        }
    }
}

extension YYLocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            if location.horizontalAccuracy > 0 {
                clmanager.stopUpdatingLocation()

                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
                currentLocation = location                
                LonLatToCity()
            }
        }
    }
}
