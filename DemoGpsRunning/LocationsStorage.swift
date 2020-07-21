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
  
  private let file: URL?
  
  private var outputStream: OutputStream?
  
  init() {
    let timestamp = Date().timeIntervalSince1970
    file = FileManager.default.temporaryDirectory.appendingPathComponent("\(timestamp)")
  }
  
  deinit {
    outputStream?.close()
  }
  
  func write(location: Location) {
    if let file = self.file, outputStream == nil {
      outputStream = OutputStream.init(toFileAtPath: file.path, append: true)
      outputStream?.open()
    } else {
      let data = ",".data(using: .ascii)!
      outputStream?.write(data.map{ $0 }, maxLength: data.map{ $0 }.count)
    }
    
    do {
      let encoder = JSONEncoder()
      let data = try encoder.encode(location)
      outputStream?.write(data.map{ $0 }, maxLength: data.map{ $0 }.count)
    } catch let error as NSError {
      print("Write data failure", error)
    }
  }
  
  func read() -> [Location] {
    guard file != nil else {
      return []
    }
    
    let decoder = JSONDecoder()
    var result = [Location]()
    
    do {
      let urls = try FileManager.default.contentsOfDirectory(at: file!, includingPropertiesForKeys: nil, options: [])
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
