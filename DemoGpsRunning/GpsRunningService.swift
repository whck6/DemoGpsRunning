//
//  GpsRunning.swift
//  DemoGpsRunning
//
//  Created by wenhao on 2020/7/5.
//  Copyright © 2020 wenhao. All rights reserved.
//

import Foundation
import CoreLocation

protocol GpsRunningServiceDelegate {
  func isReady()
  func isDenied()
  func fireTimer(timer: Timer)
}

class GpsRunningService: NSObject {
  
  private let locationManager = CLLocationManager()
  
  private var delegate: GpsRunningServiceDelegate?
  
  private var myTimer: MyTimer?
  
  init(delegate: GpsRunningServiceDelegate) {
    super.init()
    self.initLocationManager()
    self.initTimer()
    self.delegate = delegate
  }
  
  func initLocationManager() {
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.delegate = self
    self.locationManager.activityType = CLActivityType.fitness
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.distanceFilter = kCLDistanceFilterNone
    self.locationManager.allowsBackgroundLocationUpdates = true
  }
  
  func startUpdatingLocation() {
    locationManager.startUpdatingLocation()
  }
  
  func stopUpdatingLocation() {
    locationManager.stopUpdatingLocation()
  }
  
  func initTimer() {
    let timer = Timer(timeInterval: 1.0, repeats: true, block: { (timer) in
      guard self.myTimer?.isPause == false else {
        return
      }
      
      self.delegate?.fireTimer(timer: timer)
    })
    timer.tolerance = 0.1
    myTimer = MyTimer.init(timer: timer)
    RunLoop.current.add(timer, forMode: .common)
  }
  
  func startTimer() {
    if myTimer?.startDate == nil {
      myTimer?.startDate = Date()
    }
    
    myTimer?.isPause = false
    myTimer?.timer.fire()
  }
  
  func stopTimer() {
    myTimer?.isPause = true
    myTimer?.timer.invalidate()
  }
}

extension GpsRunningService: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.authorizedWhenInUse {
      delegate?.isReady()
    } else if (status == CLAuthorizationStatus.denied) {
      delegate?.isDenied()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print(locations)
    for location in locations {
      let newLocation = Location.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, date: location.timestamp)
      LocationStorage.shared.write(location: newLocation)
    }
  }
}
