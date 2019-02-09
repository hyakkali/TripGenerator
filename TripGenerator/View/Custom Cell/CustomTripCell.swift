//
//  CustomTripCell.swift
//  TripGenerator
//
//  Created by Hemanth Yakkali on 2/9/19.
//  Copyright © 2019 Hemanth Yakkali. All rights reserved.
//

import UIKit
import SwipeCellKit

class CustomTripCell : SwipeTableViewCell {
    
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var airportCodesLabel: UILabel!
    @IBOutlet weak var tripTypeLabel: UILabel!
    @IBOutlet weak var tripDatesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code goes here
    }
    
}
