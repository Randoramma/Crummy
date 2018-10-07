//
//  DateExtension.swift
//  Crummy
//
//  Created by Randy McLain on 4/20/15.
//  Copyright (c) 2015 CF. All rights reserved.
//

import Foundation

/* Extension initializes a date object calculated from an input string  */
extension Date
{
  
  init(dateString:String) {
    let dateStringFormatter = DateFormatter()
    dateStringFormatter.dateFormat = "yyyy-MM-dd"
    self.init(dateString: dateString)
  }
}
