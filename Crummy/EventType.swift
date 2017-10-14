//
//  EventType.swift
//  Crummy
//
//  Created by Josh Nagel on 4/21/15.
//  Copyright (c) 2015 CF. All rights reserved.
//

import Foundation

enum EventType: Int {
  
  case medication
  case measurement
  case symptom
  case temperature
  
  func description() -> String {
    switch self {
    case .medication:
      return "Medicine"
    case .measurement:
      return "HeightWeight"
    case .symptom:
      return "Symptom"
    case .temperature:
      return "Temperature"
//    default:
//      return String(self.rawValue)
    }
  }
  
  func filterDisplayValue() -> String {
    switch self {
    case .medication:
      return "Medications"
    case .measurement:
      return "Measurements"
    case .symptom:
      return "Symptoms"
    case .temperature:
      return "Temperatures"
//    default:
//      return String(self.rawValue)
    }
  }
}
