//
//  LocationsStorage.swift
//  DemoGpsRunning
//
//  Created by wenhao on 2020/7/5.
//  Copyright © 2020 wenhao. All rights reserved.
//

import Foundation

class LocationStorage {

  static let shared = LocationStorage()
  
  private var workDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent("locations", isDirectory: true)
  
  init() {
    do {
      var isDir: ObjCBool = false
      if FileManager.default.fileExists(atPath: workDirectoryURL.path, isDirectory: &isDir) && isDir.boolValue {
        try FileManager.default.removeItem(at: workDirectoryURL)
      }
      
      try FileManager.default.createDirectory(at: workDirectoryURL, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
      print("Unable to create directory", error)
    }
  }
  
  func write(location: Location) {
    let encoder = JSONEncoder()
    let timestamp = location.date.timeIntervalSince1970
    let fileURL = workDirectoryURL.appendingPathComponent("\(timestamp)")
    
    do {
      let data = try encoder.encode(location)
      try data.write(to: fileURL)
    } catch let error as NSError {
      print("Write data failure", error)
    }
  }
  
  func read() -> [Location] {
    let decoder = JSONDecoder()
    var result = [Location]()
    
    do {
      let urls = try FileManager.default.contentsOfDirectory(at: workDirectoryURL, includingPropertiesForKeys: nil, options: [])
      for url in urls {
        if let text = FileManager.default.contents(atPath: url.path) {
          let location = try decoder.decode(Location.self, from: text)
          result.append(location)
        }
      }
    } catch let error as NSError {
      print("Read data failure", error)
    }
    
    return result
  }
}
