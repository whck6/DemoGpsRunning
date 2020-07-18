//
//  VoiceService.swift
//  DemoGpsRunning
//
//  Created by wenhao on 2020/7/18.
//  Copyright © 2020 wenhao. All rights reserved.
//

import Foundation
import AVFoundation

class VoiceService {
  
  static let shared = VoiceService()

  private var language = NSLocale.preferredLanguages[0] // by device setting
  
  private var synthesizer: AVSpeechSynthesizer?
  
  init() {
    synthesizer = AVSpeechSynthesizer()
  }
  
  func speak(format: String = "%@", string: String) {
    let utterance = AVSpeechUtterance(string: String(format: format, string))
    utterance.voice = AVSpeechSynthesisVoice(language: language)
    utterance.pitchMultiplier = 1.2
    utterance.rate = 0.5
    synthesizer?.speak(utterance)
  }
}
