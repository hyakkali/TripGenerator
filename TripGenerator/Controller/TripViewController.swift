//
//  TripViewController.swift
//  TripGenerator
//
//  Created by Hemanth Yakkali on 1/31/19.
//  Copyright © 2019 Hemanth Yakkali. All rights reserved.
//

import UIKit
import SafariServices

class TripViewController : UIViewController {
    
    var location : String = ""
    var expediaURL : String = ""
    var kayakURL : String = ""
    var departDate : String = ""
    var arrivalDate : String = ""
    var tripType : String = ""
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tripDatesLabel: UILabel!
    @IBOutlet weak var tripTypeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationLabel.text = location
        
        print(kayakURL)
        
        formatDates()
        
        tripTypeLabel.text = tripType
        
        if (tripType == "Round Trip") {
            tripDatesLabel.text = "\(departDate) - \(arrivalDate)"
        } else {
            tripDatesLabel.text = departDate
        }
        
    }
    
    // MARK: URL Buttons
    
    @IBAction func expediaButtonPressed(_ sender: Any) {
        if let url = URL(string: expediaURL) {
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
        } else {
            print("error with expedia url")
        }
    }
    
    @IBAction func kayakButtonPressed(_ sender: Any) {
        if let url = URL(string: kayakURL) {
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - Helper Methods
    
    func formatDates() {
        departDate = departDate.replacingOccurrences(of: " ", with: "/")
        arrivalDate = arrivalDate.replacingOccurrences(of: " ", with: "/")
    }
    
    
}
