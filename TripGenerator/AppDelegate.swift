//
//  AppDelegate.swift
//  TripGenerator
//
//  Created by Hemanth Yakkali on 1/30/19.
//  Copyright © 2019 Hemanth Yakkali. All rights reserved.
//

import UIKit
import GooglePlaces
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()

        GMSPlacesClient.provideAPIKey("AIzaSyBBd2UH06e5_Ihk9RumEDKyhph4UhyP5ys")
        
        return true
    }

}

