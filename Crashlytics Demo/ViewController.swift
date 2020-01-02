//
//  ViewController.swift
//  Crashlytics Demo
//
//  Created by Ankur Baranwal on 05/11/2019.
//  Copyright © 2019 Ankur Baranwal. All rights reserved.
//

import UIKit
import Crashlytics
import EventKit
import EventKitUI

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    var stri: String!
    let appleEventStore = EKEventStore()
    var calendars: [EKCalendar]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let button = UIButton(type: .roundedRect)
        button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
    //button.setTitle("Crash", for: [])
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(crashButtonTapped), for: .touchUpInside)
        view.addSubview(button)
    }
     @objc func crashButtonTapped() {
        //Crashlytics.sharedInstance().crash()
        generateEvent()
    }
    func generateEvent() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status)
        {
        case EKAuthorizationStatus.notDetermined:
            // This happens on first-run
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            // User has access
            print("User has access to calendar")
            self.addAppleEvents()
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            // We need to help them give us permission
            noPermission()
        default:
            break
        }
        
    }
    func noPermission()
    {
        print("User has to change settings...goto settings to view access")
    }
    func requestAccessToCalendar() {
        appleEventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                DispatchQueue.main.async {
                    print("User has access to calendar")
                    self.addAppleEvents()
                }
            } else {
                DispatchQueue.main.async{
                    self.noPermission()
                }
            }
        })
    }
    func addAppleEvents()
    {
        
        let event:EKEvent = EKEvent(eventStore: appleEventStore)
        event.title = "Title"

        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = DateFormatters.serverDateFormat2
//        dateFormatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
//        let startDat = dateFormatter.date(from: startDate)
//        dateFormatter.dateFormat = DateFormatters.displayDateTimeFormat
//        dateFormatter.timeZone = TimeZone.current
//        let sDate = dateFormatter.string(from: startDat!)
//        //        dateFormatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
//        dateFormatter.timeZone = NSTimeZone.local
//        let ssDate = dateFormatter.date(from: sDate)
//
//        let dateFormatter1 = DateFormatter()
//        dateFormatter1.dateFormat = DateFormatters.serverDateFormat2
//        dateFormatter1.timeZone = NSTimeZone(name: "UTC") as! TimeZone
//        let endDat = dateFormatter1.date(from: endDate)
//        dateFormatter1.dateFormat = DateFormatters.displayDateTimeFormat
//        dateFormatter1.timeZone = TimeZone.current
//        let eDate = dateFormatter1.string(from: endDat!)
//        dateFormatter1.timeZone = NSTimeZone.local
//        //        dateFormatter1.timeZone = NSTimeZone(name: "UTC") as! TimeZone
//        let eeDate = dateFormatter1.date(from: eDate)
        
        event.startDate = Date()
        event.endDate = Date()
        
        
        let alarm = EKAlarm(relativeOffset: TimeInterval(-5*60))
        event.addAlarm(alarm)
        event.notes = "Your Task is Created." + " Total Amount is : "
        event.calendar = appleEventStore.defaultCalendarForNewEvents
        
        do {
            try
            
            print("events added with dates:")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                
                let eventModalVC = EKEventEditViewController()
                eventModalVC.event = event
                eventModalVC.eventStore = self.appleEventStore
                eventModalVC.editViewDelegate = self
                if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                    rootVC.present(eventModalVC, animated: true, completion: nil)
                }
//                var userCalendar = Calendar.current
//                var dateComponents = DateComponents.init()
//                dateComponents.year = ssDate?.year
//                dateComponents.month = ssDate?.month
//                dateComponents.day = ssDate?.day
//                let customDate = userCalendar.date(from: dateComponents)
//                let interval = (customDate?.timeIntervalSinceReferenceDate)!
//                if let url = URL(string: "calshow:\(interval)") {
//                    if #available(iOS 10.0, *) {
//                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                    } else {
//                        // Fallback on earlier versions
//                    }
//                }
                
                
            })
            
        } catch let e as NSError {
            print(e.description)
            return
        }
        print("Saved Event")
    }


}
extension ViewController: EKEventEditViewDelegate {
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
}

