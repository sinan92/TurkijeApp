//
//  ViewController.swift
//  Turkije App
//
//  Created by Sinan Samet on 02/10/2018.
//  Copyright © 2018 Sinan Samet. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        
        let center = UNUserNotificationCenter.current()
        // Request permission to display alerts and play sounds.
        center.requestAuthorization(options: [.alert, .sound])
        { (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

