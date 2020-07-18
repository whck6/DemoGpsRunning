//
//  ViewController.swift
//  DemoGpsRunning
//
//  Created by wenhao on 2020/7/5.
//  Copyright © 2020 wenhao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  var gpsRunningService: GpsRunningService?

  @IBAction func startRun(sender: UIButton) {
    print("START RUN!!")
    gpsRunningService?.startUpdatingLocation()
    print("START TIMER!!")
    gpsRunningService?.startTimer()
  }
  
  @IBAction func stopRun(sender: UIButton) {
    print("STOP RUN!!")
    gpsRunningService?.stopUpdatingLocation()
    let result = LocationStorage.shared.read()
    print(result)
    print("STOP TIMER!!")
    gpsRunningService?.stopTimer()
  }
  
  @IBOutlet weak var startRunButton: UIButton!
  @IBOutlet weak var timeLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    gpsRunningService = GpsRunningService(delegate: self)
  }
}

extension ViewController: GpsRunningServiceDelegate {
  
  func isReady() {
    print("GpsRunningService is ready!!")
    startRunButton.isEnabled = true
  }
  
  func isDenied() {
    print("GpsRunningService is denied!!")
  }
  
  func fire(timestamp: TimeInterval) {
    print(timestamp)
    timeLabel.text = Date(timeIntervalSince1970: timestamp).description
  }
  
  func updateTotalDistance(service: GpsRunningService, totalDistance: Double) {
    print("return total distance: \(totalDistance)")
    print("return signal: \(service.signalStrength)")
    
    let string = String(format: "%.f", totalDistance)
    // VoiceService.shared.speak(string: string)
    VoiceService.shared.speak(format: "you are reached %@ kilometers", string: string)
  }
}
