//
//  InterfaceController.swift
//  flush-capacitor-watchos WatchKit Extension
//
//  Created by Tomas Novella on 1/19/16.
//  Copyright © 2016 Tomas Novella. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    var count = 0
    var timer = NSTimer()
    let timerRefreshRate = 15.0
    
    var toilet = ToiletStatus()

    func displayStatus(statuses:[String:Bool]) {
        print(statuses) // L: true, R: false
    }
    func fetchStatuses() {
        dispatch_async(dispatch_get_main_queue()) {
            self.toilet.updateStatuses({ statuses in
                if (statuses.isEmpty) {
                    self.LeftToilet.setOn(false)
                    self.RightToilet.setOn(false)
                    self.refreshLabel.setText("Offline")
                    return
                }
                
                self.LeftToilet.setOn(statuses["L"]!)
                self.RightToilet.setOn(statuses["R"]!)
                self.refreshLabel.setText("")

                print(statuses)
            })
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        LeftToilet.setEnabled(false)
        RightToilet.setEnabled(false)
        
        LeftToilet.setOn(false)
        RightToilet.setOn(false)
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        fetchStatuses()
        timer = NSTimer.scheduledTimerWithTimeInterval(timerRefreshRate,
            target: self, selector: "fetchStatuses", userInfo: nil, repeats: true)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        timer.invalidate()
    }
    @IBOutlet var LeftToilet: WKInterfaceSwitch!

    @IBOutlet var RightToilet: WKInterfaceSwitch!

    @IBOutlet var refreshLabel: WKInterfaceLabel!
}
