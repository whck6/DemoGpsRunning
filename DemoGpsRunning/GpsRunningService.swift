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
  func fire(timestamp: TimeInterval)
  func updateTotalDistance(service: GpsRunningService, totalDistance: Double)
}

class GpsRunningService: NSObject {
  
  private let locationManager = CLLocationManager()
  
  private var delegate: GpsRunningServiceDelegate?
  
  private var myTimer: MyTimer?
  
  private var runingTimestamp: TimeInterval = 0.0
  
  private var lastTimestamp: TimeInterval = 0.0
  
  private var totalDistance = 0.0
  
  private var lastLocation: CLLocation?
  
  var signalStrength: SignalStrength {
    let value = lastLocation?.horizontalAccuracy
    guard value != nil else {
      return .no
    }
    
    switch Int(value!) {
    case ..<0:
      return .no
    case 163...:
      return .poor
    case 48...:
      return .average
    default:
      return .full
    }
  }
  
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
    self.locationManager.distanceFilter = 10 // avoid strange movement
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
        self.lastTimestamp = timer.fireDate.timeIntervalSince1970
        return
      }
      self.runingTimestamp += (timer.fireDate.timeIntervalSince1970  - self.lastTimestamp)
      self.delegate?.fire(timestamp: self.runingTimestamp)
      self.lastTimestamp = timer.fireDate.timeIntervalSince1970
    })
    timer.tolerance = 0.1
    RunLoop.current.add(timer, forMode: .common)
    myTimer = MyTimer.init(timer: timer, startDates: [])
  }
  
  func startTimer() {
    myTimer?.startDates.append(Date())
    myTimer?.isPause = false
  }
  
  func stopTimer() {
    myTimer?.isPause = true
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
      totalDistance += location.distance(from: lastLocation ?? location)
      lastLocation = location
      delegate?.updateTotalDistance(service: self, totalDistance: totalDistance)
    }
  }
}

enum SignalStrength: Int {
  case no
  case poor
  case average
  case full
}
