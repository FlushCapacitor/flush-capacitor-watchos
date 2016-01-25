//
//  ToiletStatus.swift
//  fluxCapacitor
//
//  Created by Tomas Novella on 1/8/16.
//  Copyright © 2016 Tomas Novella. All rights reserved.
//

import Foundation

func httpGet(request: NSURLRequest!, callback: (String, String?) -> Void) {
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request){
        (data, response, error) -> Void in
        dispatch_async(dispatch_get_main_queue()) {
            if error != nil {
                callback("", error!.localizedDescription)
            } else {
                let result = NSString(data: data!, encoding:
                    NSASCIIStringEncoding)!
                callback(result as String, nil)
            }
        }
    }
    task.resume()
}

class ToiletStatus /*: NSObject, SRWebSocketDelegate */{
    let kWebSocketURL = "ws://itoilet/changes"
    let kHTTPQueryURL = "http://itoilet/api/sensors"
    
    //MARK public API
    func updateStatuses(callback: [String:Bool]->Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: kHTTPQueryURL)!)
        
        httpGet(request) { (data, error) -> Void in
            
            var _statuses = [String:Bool]()
            if error != nil {
                _statuses.removeAll()
            } else {
                let jsonizedMessage = try? NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options:[])
                guard let responseJson = jsonizedMessage as? [[String:String]] else {
                    return
                }
                
                // example: toilet = {"name": "L", state: "unlocked"}
                for toilet in responseJson {
                    _statuses[toilet["name"]!] = toilet["state"]! == "unlocked"
                }
            }
            callback(_statuses)
            //callback(["L": false, "R": true])
            print("@@ \(_statuses)")
        }
    }
    
    
}