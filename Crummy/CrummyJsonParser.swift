//
//  CrummyKidJsonParser.swift
//  Crummy
//
//  Created by Ed Abrahamsen on 4/21/15.
//  Copyright (c) 2015 CF. All rights reserved.
//
import Foundation

class CrummyJsonParser {
  
  class func parseJsonListKid(_ jsonData: Data) -> [Kid] {
    var parse = [Kid]()
    var _: NSError?
    //TODO: SERIALIZE JSON
//    if let jsonArray = JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String: AnyObject]] {
//
//      for object in jsonArray {
//        let name = object["name"] as! String
//        let kidId = object["id"] as! Int
//        let id = "\(kidId)"
//        let dob = object["dob"] as? String
//        let insuranceId = object["insurance_id"] as? String
//        let nursePhone = object["nurse_phone"] as? String
//        let notes = object["notes"] as? String  // Add notes when Kid obbject updated
//        let kid = Kid(theName: name, theDOB: dob, theInsuranceID: insuranceId, theNursePhone: nursePhone, theNotes: notes, theKidID: id)
//        parse.append(kid)
//      }
//    }
    return parse
  }
  
  class func parseJsonGetKid(_ jsonData: Data) -> Kid {
    var editMenuKid: Kid!
    var _: NSError?
    
    //TODO: SERIALIZE JSON
//    if let
//      jsonDictionary = JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
//
//      let name = jsonDictionary["name"] as! String
//      let kidId = jsonDictionary["id"] as! Int
//      let id = String(stringInterpolationSegment: kidId)
//      let dob = jsonDictionary["dob"] as? String
//      let insuranceId = jsonDictionary["insurance_id"] as? String
//      let nursePhone = jsonDictionary["nurse_phone"] as? String
//      let notes = jsonDictionary["notes"] as? String  // Add notes when Kid obbject updated
//      editMenuKid = Kid(theName: name, theDOB: dob, theInsuranceID: insuranceId, theNursePhone: nursePhone, theNotes: notes, theKidID: id)
//    }
    return editMenuKid
  }
  
  class func parseEvents(_ jsonData: Data) -> [Event] {
    var events = [Event]()
    var error: NSError?
    
        //TODO: SERIALIZE JSON
//    if let jsonObject = JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String: AnyObject]] {
//      for event in jsonObject {
//        if let eventId = event["id"] as? Int {
//          var id = "\(eventId)"
//          var eventType: EventType?
//          var name: String?
//          var temperature: String?
//          var height: String?
//          var weight: String?
//          var description: String?
//          var date: NSDate?
//          if let type = event["type"] as? String {
//            if type == "Medicine" {
//              eventType = EventType.medication
//            } else if type == "Temperature" {
//              eventType = EventType.temperature
//            } else if type == "HeightWeight" {
//              eventType = EventType.measurement
//            } else {
//              eventType = EventType.symptom
//            }
//          }
//          if let datetime = event["datetime"] as? String {
//            //Need dateFormatter
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//            date = dateFormatter.date(from: datetime) as! NSDate
//          }
//          if let eventName = event["meds"] as? String {
//            name = eventName
//          }
//          if let eventTemperature = event["temperature"] as? String {
//            temperature = eventTemperature
//          }
//          if let eventHeight = event["height"] as? String {
//            height = eventHeight
//          }
//          if let eventWeight = event["weight"] as? String {
//            weight = eventWeight
//          }
//          if let eventDescription = event["description"] as? String {
//            description = eventDescription
//          }
//          
//          let event = Event(id: id, type: eventType!, temperature: temperature, medication: name, height: height, weight: weight, symptom: description, date: date! as Date)
//          events.append(event)
//        }
//      }
//    }
    return events
  }
  
  class func getEventId(_ data: Data) -> String? {
        //TODO: SERIALIZE JSON
//    if let event = JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject], let id = event["id"] as? Int {
//      return "\(id)"
//    }
    return nil
  }
}
