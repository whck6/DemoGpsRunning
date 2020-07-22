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
  
  private var inputStream: InputStream?
  
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
      if let data = "\n".data(using: .utf8) {
        outputStream?.write(data.map{ $0 }, maxLength: data.map{ $0 }.count)
      }
    }
    
    do {
      let encoder = JSONEncoder()
      let data = try encoder.encode(location)
      outputStream?.write(data.map{ $0 }, maxLength: data.map{ $0 }.count)
    } catch {
      print("Write data failure", error)
    }
  }
  
  func read() -> [Location] {
    guard file != nil else {
      return []
    }
    
    if let file = self.file, inputStream == nil {
      inputStream = InputStream.init(fileAtPath: file.path)
      inputStream?.open()
    }
    
    let bufferSize = 1024
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    defer {
        buffer.deallocate()
    }
    
    var data = Data.init()
    
    do {
      while inputStream!.hasBytesAvailable {
          let read = inputStream!.read(buffer, maxLength: bufferSize)
          if read < 0 {
              //Stream error occured
            throw inputStream!.streamError!
          } else if read == 0 {
              //EOF
              break
          }
          data.append(buffer, count: read)
      }
    } catch {
      print("Read data failure", error)
    }
    
    var locations = [Location]()
    
    do {
      let decoder = JSONDecoder()
      let elements = String(decoding: data, as: UTF8.self).split(separator: "\n")
      
      try elements.forEach { element in
        if let data = element.data(using: .utf8) {
          let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
          let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
          let location = try decoder.decode(Location.self, from: jsonData)
          locations.append(location)
        }
      }
    } catch {
      print("Decode data failure", error)
    }
    
    inputStream?.close()
    inputStream = nil
    
    return locations
  }
}
