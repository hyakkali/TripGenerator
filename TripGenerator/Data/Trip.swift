//
//  Trip.swift
//  TripGenerator
//
//  Created by Hemanth Yakkali on 2/1/19.
//  Copyright © 2019 Hemanth Yakkali. All rights reserved.
//

import Foundation
import RealmSwift

class Trip : Object {
    @objc dynamic var origin : String = ""
    @objc dynamic var destination : String = ""
    @objc dynamic var departDate : String = ""
    @objc dynamic var arrivalDate : String = ""
    @objc dynamic var tripType : String = ""
    @objc dynamic var expediaURL : String = ""
    @objc dynamic var kayakURL : String = ""
}
