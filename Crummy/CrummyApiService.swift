//
//  CrummyApiService.swift
//  Crummy
//
//  Created by Ed Abrahamsen on 4/21/15.
//  Copyright (c) 2015 CF. All rights reserved.
//
import Foundation

enum RequestType {
    case POST
    case KID
    case EVENTS
    
    
}


class CrummyApiService {
    
    static let sharedInstance: CrummyApiService = CrummyApiService()
    
    let baseUrl = "http://crummy.herokuapp.com/api/v1"
    
    func postLogin(_ username: String, password: String, completionHandler: @escaping (String?, String?) -> (Void)) {
        
        let request = requestBuilder(username: username, password: password, token: nil)
        // configure the URLSession
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                print(error?.localizedDescription ?? "Default Error Message: Error at: GET request (http://crummy.herokuapp.com/api/v1/sessions)")
                return
            }
            guard let responseData = data else {
                assert(false, "Recieved no data for GET request (http://crummy.herokuapp.com/api/v1/sessions)")
                return
            }
            let status = self.statusResponse(response!)
            if status == "200" {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                        print("error trying to convert data to JSON")
                        return
                    }
                    guard let token: String = json["authentication_token"] as? String else {
                        return;
                    }
                    UserDefaults.standard.set(token, forKey: "crummyToken")
                    UserDefaults.standard.synchronize()
                    OperationQueue.main.addOperation({
                        completionHandler(status, nil)
                    })
                } catch  {
                    assert(false, "GET request returned connection status of: \(status)")
                }
            } else {
                //TODO: Notify user of connection issue.
            }
        }
        dataTask.resume()
    }
    
    func createNewUser(_ username: String, password: String, completionHandler: @escaping (String?, String?) -> (Void)) {
        
        let request = requestBuilder(username: username, password: password, token: nil)
        
        //TODO: URLSESSION data task with request
        //    let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
        //      if error != nil {
        //        completionHandler(nil, error.description)
        //      } else {
        //        let status = self.statusResponse(response)
        //        if status == "200" {
        //          OperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        //            completionHandler(status, nil)
        //          })
        //        } else {
        //          OperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        //            completionHandler(nil, status)
        //          })
        //        }
        //      }
        //    })
        //    dataTask.resume()
    }
    
    func listKid(_ completionHandler: @escaping ([Kid]?, String?) -> (Void)) {
        
        let requestUrl = "http://crummy.herokuapp.com/api/v1/kids"
        
        let url = URL(string: requestUrl)
        let request = NSMutableURLRequest(url: url!)
        if let token = UserDefaults.standard.object(forKey: "crummyToken") as? String {
            request.setValue("Token token=\(token)", forHTTPHeaderField: "Authorization")
        }
        //TODO: URLSESSION data task with request
        //    let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
        //      if error != nil {
        //        completionHandler(nil, error.description)
        //      } else {
        //        let status = self.statusResponse(response)
        //        if status == "200" {
        //          let parsedKids = CrummyJsonParser.parseJsonListKid(data)
        //          OperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        //              completionHandler(parsedKids, nil)
        //          })
        //        }
        //      }
        //    })
        //    dataTask.resume()
    }
    
    func getKid(_ id: String, completionHandler: @escaping (Kid?, String?) -> (Void)) {
        
        let kidIdUrl = "http://crummy.herokuapp.com/api/v1/kids/"
        let queryString = id
        let requestUrl = kidIdUrl + queryString
        let url = URL(string: requestUrl)
        let request = NSMutableURLRequest(url: url!)
        if let token = UserDefaults.standard.object(forKey: "crummyToken") as? String {
            request.setValue("Token token=\(token)", forHTTPHeaderField: "Authorization")
        }
        
        
        //TODO: URLSESSION data task with request
        //    let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
        //      if error != nil {
        //        completionHandler(nil, error.description)
        //      } else {
        //        let status = self.statusResponse(response)
        //        if status == "200" {
        //          let editMenuKid = CrummyJsonParser.parseJsonGetKid(data)
        //          OperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        //            completionHandler(editMenuKid, nil)
        //          })
        //        } else {
        //          completionHandler(nil,status)
        //        }
        //      }
        //    })
        //    dataTask.resume()
    }
    
    func editKid(_ id: String, name: String, dobString: String?, insuranceID: String?, nursePhone: String?, notes: String?, completionHandler: @escaping (String?, String?) -> Void) {
        let kidIdUrl = "http://crummy.herokuapp.com/api/v1/kids/"
        let queryString = id
        let requestUrl = kidIdUrl + queryString
        let url = URL(string: requestUrl)
        var error: NSError?
        var editedKid = [String: AnyObject]()
        
        editedKid["name"] = name as AnyObject
        if let kidDob = dobString {
            editedKid["dob"] = kidDob as AnyObject
        }
        if let kidInsuranceId = insuranceID {
            editedKid["insurance_id"] = kidInsuranceId as AnyObject
        }
        if let kidNursePhone = nursePhone {
            editedKid["nurse_phone"] = kidNursePhone as AnyObject
        }
        if let kidNotes = notes {
            editedKid["notes"]  = kidNotes as AnyObject
        }
        
        //TODO: URLSESSION data task with request
        //    let data = JSONSerialization.dataWithJSONObject(editedKid, options: nil, error: &error)
        //    let request = NSMutableURLRequest(url: url!)
        //    request.httpMethod = "PATCH"
        //    request.HTTPBody = data
        //    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //    if let token = UserDefaults.standard.object(forKey: "crummyToken") as? String {
        //      request.setValue("Token token=\(token)", forHTTPHeaderField: "Authorization")
        //    }
        //    let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
        //      if error != nil {
        //        completionHandler(nil, error.description)
        //      } else {
        //        let status = self.statusResponse(response)
        //        if status == "200" {
        //          OperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        //            completionHandler(status, nil)
        //          })
        //        } else {
        //          OperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        //            completionHandler(nil, status)
        //          })
        //        }
        //      }
        //    })
        //    dataTask.resume()
    }
    
    func deleteKid(_ id: String, completionHandler: @escaping (String) -> (Void)) {
        
        let kidIdUrl = "http://crummy.herokuapp.com/api/v1/kids/"
        let queryString = id
        let requestUrl = kidIdUrl + queryString
        let url = URL(string: requestUrl)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "DELETE"
        if let token = UserDefaults.standard.object(forKey: "crummyToken") as? String {
            request.setValue("Token token=\(token)", forHTTPHeaderField: "Authorization")
        }
        //TODO: URLSESSION data task with request
        //    let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
        //
        //      let status = self.statusResponse(response)
        //      if status == "200" {
        //
        //        OperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        //          completionHandler(status)
        //        })
        //        } else {
        //        OperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        //          completionHandler(status)
        //        })
        //      }
        //    })
        //    dataTask.resume()
    }
    
    func postNewKid(_ name: String, dobString: String?, insuranceID: String?, nursePhone: String?, notes: String?, completionHandler: @escaping (String?, String?) -> Void) {
        // url
        let requestUrl = "http://crummy.herokuapp.com/api/v1/kids"
        let url = URL(string: requestUrl)
        var request = NSMutableURLRequest(url: url!)
        var error: NSError?
        var editedKid = [String: AnyObject]()
        editedKid["name"] = name as AnyObject
        if let kidDob = dobString {
            editedKid["dob"] = kidDob as AnyObject
        }
        if let kidInsuranceId = insuranceID {
            editedKid["insurance_id"] = kidInsuranceId as AnyObject
        }
        if let kidNursePhone = nursePhone {
            editedKid["nurse_phone"] = kidNursePhone as AnyObject
        }
        if let kidNotes = notes {
            editedKid["notes"]  = kidNotes as AnyObject
        }
        
        //TODO: URLSESSION data task with request
        //    let data = JSONSerialization.dataWithJSONObject(editedKid, options: nil, error: &error)
        //    request.httpMethod = "POST"
        //    request.HTTPBody = data
        //    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //
        //    // token
        //    if let token = UserDefaults.standard.object(forKey: "crummyToken") as? String {
        //      request.setValue("Token token=\(token)", forHTTPHeaderField: "Authorization")
        //    }
        //post
        
        //    let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
        //      let status = self.statusResponse(response)
        //      var error: NSError?
        
        //TODO: SERIALIZE JSON
        //      if status == "201" || status == "200" {
        //        if let jsonObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? [String: AnyObject], let id = jsonObject["id"] as? Int {
        //          let kidID = "\(id)"
        //          OperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        //            completionHandler(kidID, status)
        //          })
        //        }
        //      } else {
        //        OperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        //          completionHandler(nil, status)
        //        })
        //      }
        //    })
        //
        //    dataTask.resume()
    } // postNewKid
    
    func getEvents(_ id: String, completionHandler: @escaping ([Event]?, String?) -> (Void)) {
        let eventUrl = "\(self.baseUrl)/kids/\(id)/events/"
        let url = URL(string: eventUrl)
        
        let request = NSMutableURLRequest(url: url!)
        if let token = UserDefaults.standard.object(forKey: "crummyToken") as? String {
            request.setValue("Token token=\(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        //TODO: URLSESSION data task with request
        //    let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
        //      if error != nil {
        //
        //      } else {
        //        if let httpResponse = response as? HTTPURLResponse {
        //          if httpResponse.statusCode == 200 {
        //            let events = CrummyJsonParser.parseEvents(data)
        //
        //            OperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        //              completionHandler(events, nil)
        //            })
        //          }
        //        }
        //      }
        //    })
        //    dataTask.resume()
    }
    
    func deleteEvent(_ kidId: String, eventId: String, completionHandler: @escaping (String?, String?) -> (Void)) {
        let deleteEventUrl = "\(self.baseUrl)/kids/\(kidId)/events/\(eventId)"
        //    let deleteEventUrl = "http://crummy.herokuapp.com/api/v1/kids/45/events/144"
        let url = URL(string: deleteEventUrl)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "DELETE"
        request.setValue("Token token=nvZPt85uUZKh3itdoQkz", forHTTPHeaderField: "Authorization")
        //TODO: URLSESSION data task with request
        //    let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
        //      if error != nil {
        //        completionHandler(nil, error.description)
        //      } else {
        //        if let httpResponse = response as? HTTPURLResponse {
        //          if httpResponse.statusCode == 204 {
        //            OperationQueue.main.addOperation({ () -> Void in
        //              completionHandler(eventId, nil)
        //            })
        //          }
        //        }
        //      }
        //    })
        //    dataTask.resume()
    }
    
    func createEvent(_ kidId: String, event: Event, completionHandler: @escaping (String?, String?) -> (Void)) {
        let createEventUrl = "\(self.baseUrl)/kids/\(kidId)/events/"
        let url = URL(string: createEventUrl)
        var error: NSError?
        
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let eventDate = dateFormatter.string(from: event.date as Date)
        
        var newEvent = [String: AnyObject]()
        newEvent["datetime"] = eventDate as AnyObject
        newEvent["type"] = event.type.description() as AnyObject
        if let eventTemperature = event.temperature {
            newEvent["temperature"] = eventTemperature as AnyObject
        }
        if let eventHeight = event.height {
            newEvent["height"] = "\(eventHeight)" as AnyObject
        }
        if let eventWeight = event.weight {
            newEvent["weight"] = "\(eventWeight)" as AnyObject
        }
        if let eventDescription = event.symptom {
            newEvent["description"] = eventDescription as AnyObject
        }
        if let eventMeds = event.medication {
            newEvent["meds"] = eventMeds as AnyObject
        }
        
        
        //    let data = JSONSerialization.dataWithJSONObject(newEvent, options: nil, error: &error)
        //
        //    let request = NSMutableURLRequest(url: url!)
        //    request.httpMethod = "POST"
        //    request.HTTPBody = data
        //    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //    if let token = UserDefaults.standard.object(forKey: "crummyToken") as? String {
        //      request.setValue("Token token=\(token)", forHTTPHeaderField: "Authorization")
        //    }
        //TODO: URLSESSION data task with request
        //    let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
        //      if error != nil {
        //        completionHandler(nil, error.description)
        //      } else {
        //        if let httpResponse = response as? HTTPURLResponse {
        //          if httpResponse.statusCode == 201 {
        //            if data != nil {
        //              if let id = CrummyJsonParser.getEventId(data) {
        //                OperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        //                  completionHandler(id, nil)
        //                })
        //              }
        //            }
        //          }
        //        }
        //      }
        //    })
        //    dataTask.resume()
    }
    
    func editEvent(_ kidId: String, event: Event, completionHandler: @escaping (Event?, String?) -> (Void)) {
        let updateEventUrl = "\(self.baseUrl)/kids/\(kidId)/events/\(event.id!)"
        let url = URL(string: updateEventUrl)
        var error: NSError?
        
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let eventDate = dateFormatter.string(from: event.date as Date)
        
        var updatedEvent = [String: AnyObject]()
        updatedEvent["datetime"] = eventDate as AnyObject
        updatedEvent["type"] = event.type.description() as AnyObject
        if let eventTemperature = event.temperature {
            updatedEvent["temperature"] = eventTemperature as AnyObject
        }
        if let eventHeight = event.height {
            updatedEvent["height"] = "\(eventHeight)" as AnyObject
        }
        if let eventWeight = event.weight {
            updatedEvent["weight"] = "\(eventWeight)" as AnyObject
        }
        if let eventDescription = event.symptom {
            updatedEvent["description"] = eventDescription as AnyObject
        }
        if let eventMeds = event.medication {
            updatedEvent["meds"] = eventMeds as AnyObject
        }
        
        //TODO: SERIALIZE JSON
        //    let data = JSONSerialization.dataWithJSONObject(updatedEvent, options: nil, error: &error)
        //
        //    let request = NSMutableURLRequest(url: url!)
        //    request.httpMethod = "PATCH"
        //    request.HTTPBody = data
        //    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //    if let token = UserDefaults.standard.object(forKey: "crummyToken") as? String {
        //      request.setValue("Token token=\(token)", forHTTPHeaderField: "Authorization")
        //    }
        
        //TODO: URLSESSION data task with request
        //    let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
        //      if error != nil {
        //        completionHandler(nil, error.description)
        //      } else {
        //        if let httpResponse = response as? HTTPURLResponse {
        //          if httpResponse.statusCode == 200 {
        //            OperationQueue.main.addOperation({ () -> Void in
        //              completionHandler(event, nil)
        //            })
        //          }
        //        }
        //      }
        //    })
        //    dataTask.resume()
    }
    
    fileprivate func requestBuilder(username usr: String?, password pw: String?,  token tk: String? )-> URLRequest {
        
        // Types of requests
        //"http://crummy.herokuapp.com/api/v1/sessions"
        //"http://crummy.herokuapp.com/api/v1/kids"
        //"http://crummy.herokuapp.com/api/v1/kids/45/events/144"
        //"\(self.baseUrl)/kids/\(kidId)/events/\(event.id!)
        //
        /*
         let requestUrl = "http://crummy.herokuapp.com/api/v1/kids"
         
         let url = URL(string: requestUrl)
         let request = NSMutableURLRequest(url: url!)
         if let token = UserDefaults.standard.object(forKey: "crummyToken") as? String {
         request.setValue("Token token=\(token)", forHTTPHeaderField: "Authorization")
         }
         */
        let url: URL = URL(string: "http://crummy.herokuapp.com/api/v1/sessions")!
        let data: Data
        var request = URLRequest(url: url)
        if let username = usr {
            if let password = pw {
                let parameterString = "email=\(username)" + "&" + "password=\(password)"
                data = parameterString.data(using: String.Encoding.ascii, allowLossyConversion: true)!
                request.httpBody = data
            }
        } else {
            if let token = tk {
                
            }
        }
        
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    func statusResponse(_ response: URLResponse) -> String {
        
        if let httpResponse = response as? HTTPURLResponse {
            let httpStatus = httpResponse.statusCode
            
            switch httpStatus {
            case 200:
                return "200"
            case 201:
                return "200"
            case 400:
                return "Problems parsing JSON"
            case 401:
                return "Incorrect username or password"
            case 404:
                return "Object does not exist"
            case 422:
                return "Validation failed"
            default:
                return "Unkown error"
            }
        }
        return "Unknown error"
    }
}
