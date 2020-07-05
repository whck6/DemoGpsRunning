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
  
  func fireTimer(timer: Timer) {
    print(timer.fireDate)
    timeLabel.text = timer.fireDate.description
  }
}
