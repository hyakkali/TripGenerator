//
//  TripViewController.swift
//  TripGenerator
//
//  Created by Hemanth Yakkali on 1/31/19.
//  Copyright © 2019 Hemanth Yakkali. All rights reserved.
//

import UIKit

class TripViewController : UIViewController {
    
    var location : String = ""
    var expediaURL : String = ""
    var kayakURL : String = ""
    var travelDates : [String] = []
    
    @IBOutlet weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationLabel.text = location
    }
    
    
    
}
