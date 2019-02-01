//
//  Place.swift
//  TripGenerator
//
//  Created by Hemanth Yakkali on 2/1/19.
//  Copyright © 2019 Hemanth Yakkali. All rights reserved.
//

import Foundation
import RealmSwift

class Place : Object {
    @objc dynamic var name : String = ""
    @objc dynamic var airportCode : String = ""
    
    override static func primaryKey() -> String? {
        return "name"
    }
}
