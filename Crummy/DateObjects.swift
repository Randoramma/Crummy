//
//  DateObjects.swift
//  Crummy
//
//  Created by Randy McLain on 5/3/15.
//  Copyright (c) 2015 CF. All rights reserved.
//

import Foundation

class DateObject {
  
  var dateFormatter = DateFormatter()
  
  // we want to convert a string to "dd-MM-yyyy"
  
  func convertddMMYYYYToString (_ theDate : Date) -> (String) {
    
     dateFormatter.dateFormat = "dd-MM-yyyy"
    let stringDate = dateFormatter.string(from: theDate)
    
    return stringDate
    
  }
}
