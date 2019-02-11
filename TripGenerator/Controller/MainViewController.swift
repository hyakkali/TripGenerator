//
//  ViewController.swift
//  TripGenerator
//
//  Created by Hemanth Yakkali on 1/30/19.
//  Copyright © 2019 Hemanth Yakkali. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import RealmSwift
import ChameleonFramework

class MainViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let realm = try! Realm()
    var placeArray : Results<Place>?
    
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var tripTypeTextField: UITextField!
    
    @IBOutlet weak var greetingLabel: UILabel!
    
    let originList = ["RDU", "BOS", "JFK", "LGA", "EWR", "SFO"]
    let tripTypeList = ["Round Trip", "One Way"]
    let cityList = ["Paris", "London", "Bangkok", "Singapore", "New York", "Kuala Lumpur", "Hong Kong", "Dubai", "Istanbul", "Rome", "Shanghai", "Los Angeles", "Las Vegas", "Miami", "Toronto", "Barcelona", "Dublin", "Amsterdam", "Moscow", "Cairo", "Prague", "Vienna", "Madrid", "San Francisco", "Vancouver", "Budapest", "Rio de Janeiro", "Berlin", "Tokyo", "Mexico City", "Buenos Aires", "St. Petersburg", "Seoul", "Athens", "Jerusalem", "Seattle", "Delhi", "Sydney", "Mumbai", "Munich", "Venice", "Florence", "Beijing", "Cape Town", "Washington D.C.", "Montreal", "Atlanta", "Boston", "Philadelphia", "Chicago", "San Diego", "Stockholm", "Cancun", "Warsaw", "Sharm el-Sheikh", "Dallas", "Ho Chi Minh City", "Milan", "Oslo", "Lisbon", "Punta Cana", "Johannesburg", "Antalya", "Mecca", "Macau", "Pattaya", "Guangzhou", "Kiev", "Shenzhen", "Bucharest", "Taipei", "Orlando", "Brussels", "Chennai", "Marrakesh", "Phuket", "Edirne", "Bali", "Copenhagen", "Sao Paulo", "Agra", "Varna", "Riyadh", "Jakarta", "Auckland", "Honolulu", "Edinburgh", "Wellington", "New Orleans", "Petra", "Melbourne", "Luxor", "Hanoi", "Manila", "Houston", "Phnom Penh", "Zurich", "Lima", "Santiago", "Bogota"]
    
    let noAirportDict : [String : String] = [
        "Mecca" : "JED",
        "Edirne" : "IST",
        "Petra" : "AMM",
        "Jerusalem" : "TLV",
        "Washington D.C." : "IAD"
    ]
    
    let noPlaceIDDict : [String : String] = [
        "Barcelona" : "Barcelona, Spain",
        "Mecca" : "Mecca, Saudi Arabia"
    ]
    
    // URL to get valid airport code
    let AIRPORT_URL = "https://iatacodes.org/api/v6/autocomplete?api_key=9e145a85-8a4f-4f41-aaf3-e807721840ff&query="
    let PLACES_URL = "https://maps.googleapis.com/maps/api/place/textsearch/json?query="
    let KEY = "&key="
    let PLACES_API_KEY = "AIzaSyB8AVDjX7tbuZqTyOQZuwKcur7MZM6QE0M"
    var expedia_url = ""
    var kayak_url = ""
    var departDate = ""
    var arrivalDate = ""
    var origin = "RDU"
    var destination = ""
    var destAirportCode = ""
    var destPlaceID = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = FlatWhite()
        
        setupPickerViews()
        displayGreeting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
        navBar.barTintColor = HexColor("#42eef4")
        navBar.tintColor = ContrastColorOf(HexColor("#42eef4")!, returnFlat: true)
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(HexColor("#42eef4")!, returnFlat: true)]
    }
    
    func setupPickerViews() {
        let originPickerView = UIPickerView()
        let tripTypePickerView = UIPickerView()
        
        originPickerView.delegate = self
        tripTypePickerView.delegate = self
        
        originTextField.inputView = originPickerView
        tripTypeTextField.inputView = tripTypePickerView
        
        originPickerView.tag = 1
        tripTypePickerView.tag = 2
        
        originTextField.text = originList[0]
        tripTypeTextField.text = tripTypeList[0]
    }
    
    // MARK: - PickerView Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { // number of columns
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { // number of rows
        return pickerView.tag == 1 ? originList.count : tripTypeList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { // sets title for each row
        return pickerView.tag == 1 ? originList[row] : tripTypeList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) { // set text of textfield to row value
        if pickerView.tag == 1 {
            originTextField.text = originList[row]
            origin = originList[row]
        } else {
            tripTypeTextField.text = tripTypeList[row]
        }
        
        self.view.endEditing(true)
    }
    
    // MARK: - Buttons
    
    @IBAction func generateTrip(_ sender: Any) {
        
        let number : Int = Int.random(in: 0 ..< cityList.count)
        destination = cityList[number]

        while ((origin == "BOS" && destination == "Boston") || ((origin == "JFK" || origin == "EWR" || origin == "LGA") && destination == "New York") || (origin == "SFO" && destination == "San Francisco")) {
            let number : Int = Int.random(in: 0 ..< cityList.count)
            destination = cityList[number]
        }
        
        // check if destination is an attribute on any places
        let destinationData = realm.objects(Place.self).filter("name = %@", destination)
        
        if (!destinationData.isEmpty) { // if place exists in database
            destAirportCode = (destinationData.first?.airportCode)!
            getAttractions()
        } else {
            Alamofire.request(AIRPORT_URL + formatCityName(city: destination), method: .get).responseJSON { (response) in
                if response.result.isSuccess {
                    print("Got airport data!")
                    let body : JSON = JSON(response.result.value!)
                    self.destAirportCode = body["response"]["airports_by_cities"][0]["code"].stringValue
                    print(self.destination)
                    print(self.destAirportCode)
                    
                    // if airport code empty, check dict to get the right airport code
                    if self.destAirportCode == "" {
                        self.destAirportCode = self.noAirportDict[self.destination]!
                    }
                    
                    self.createPlace()
                    self.getAttractions()
                    
                } else {
                    print("Error \(response.result.error!)")
                }
            }
        }
    
    }
    
    @IBAction func tripsButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "goToFavTrips", sender: self)
    }

    func getAttractions() {
        var url = PLACES_URL + formatCityName(city: destination) + KEY + PLACES_API_KEY
        if destination == "Barcelona" || destination == "Mecca" {
            url = PLACES_URL + formatCityName(city: noPlaceIDDict[destination]!) + KEY + PLACES_API_KEY
        }
        Alamofire.request(url , method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                print("got places data!")
                let body : JSON = JSON(response.result.value!)
                self.destPlaceID = body["results"][0]["place_id"].string!
                self.generateTripDetails()
            } else {
                print("Error in places API \(response.result.error!)")
            }
        }
    }
    
    func generateTripDetails() {
        self.generateRandomDates()
        
        if (self.tripTypeTextField.text! == "Round Trip") {
            self.generateRTExpediaURL()
            self.generateRTKayakURL()
        } else {
            self.generateOWExpediaURL()
            self.generateOWKayakURL()
        }
        
        self.performSegue(withIdentifier: "goToTripPage", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToTripPage") {
            let destinationVC = segue.destination as! TripViewController
            destinationVC.trip = createTrip()
        }
    }
    
    // MARK: - Date Functions
    
    func generateRandomDates() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM dd y"
        let currentDate = dateFormatter.string(from: Date())

        let currentDateArr = currentDate.split(separator: " ")

        let currMonth = Int(currentDateArr[0])
        let currYear = Int(currentDateArr[2])

        let departMonth : Int = Int.random(in: (currMonth! + 1) ... (currMonth! + 8)) // generate random month from next month to Dec
        let departDay = generateRandomDay(month: departMonth)
        
        var arrMonth = 0
        var arrYear = 0
        
        // if depart month is december, add one to year and set arrival month to jan
        arrYear = departMonth == 12 ? currYear! + 1 : currYear!
        arrMonth = departMonth == 12 ? 1 : departMonth + 1
        
        let arrDay = generateRandomDay(month: arrMonth)
        
        departDate = String(departMonth) + " " + String(departDay) + " " + String(currYear!)
        arrivalDate = String(arrMonth) + " " + String(arrDay) + " " + String(arrYear)
    }
    
    func generateRandomDay(month : Int) -> Int {
        if (month == 4 ||  month == 6 || month == 9 || month == 11) {
            return Int.random(in: 1 ... 30)
        } else if (month == 2) {
            return Int.random(in: 1 ... 28)
        } else {
            return Int.random(in: 1 ... 31) // else month is a month with 31 days
        }
    }
    
    func displayGreeting() {
        let date = NSDate()
        let calendar = NSCalendar.current
        let currHour = calendar.component(.hour, from: date as Date)
        let hour = Int(currHour.description)!
        
        if (hour >= 0 && hour <= 7) {
            greetingLabel.text = "Go to sleep baby!"
        } else if (hour >= 7 && hour <= 12) {
            greetingLabel.text = "Good morning cutie :)"
        } else if (hour >= 12 && hour <= 16) {
            greetingLabel.text = "Hi babe!"
        } else if (hour >= 16 && hour <= 20) {
            greetingLabel.text = "Hi baby!"
        } else if (hour >= 20 && hour <= 24) {
            greetingLabel.text = "Good night cutie baby!"
        }

    }
    
    // MARK: - Generate URLS
    
    func generateRTExpediaURL() {
        let departDateArr = departDate.split(separator: " ")
        let arrivalDateArr = arrivalDate.split(separator: " ")
        
        let departMonth = departDateArr[0]
        let departDay = departDateArr[1]
        let departYear = departDateArr[2]
        
        let arrMonth = arrivalDateArr[0]
        let arrDay = arrivalDateArr[1]
        let arrYear = arrivalDateArr[2]
        
        expedia_url = "https://www.expedia.com/Flights-Search?trip=roundtrip&leg1=from:\(origin),to:\(destAirportCode),departure:\(departMonth)/\(departDay)/\(departYear)TANYT&leg2=from:\(destAirportCode),to:\(origin),departure:\(arrMonth)/\(arrDay)/\(arrYear)TANYT&passengers=adults:1,children:0,seniors:0,infantinlap:Y&options=cabinclass:economy&mode=search&origref=www.expedia.com"
    }
    
    func generateOWExpediaURL() {
        let departDateArr = departDate.split(separator: " ")
        
        let departMonth = departDateArr[0]
        let departDay = departDateArr[1]
        let departYear = departDateArr[2]
        
        expedia_url = "https://www.expedia.com/Flights-Search?trip=oneway&leg1=from:\(origin),to:\(destAirportCode),departure:\(departMonth)/\(departDay)/\(departYear)TANYT&passengers=adults:1,children:0,seniors:0,infantinlap:Y&options=cabinclass:economy&mode=search&origref=www.expedia.com"
    }
    
    func generateRTKayakURL() {
        let departDateArr = departDate.split(separator: " ")
        let arrivalDateArr = arrivalDate.split(separator: " ")
        
        let departMonth = addHeaderZero(number: String(departDateArr[0]))
        let departDay = addHeaderZero(number: String(departDateArr[1]))
        let departYear = departDateArr[2]
        
        let arrMonth = addHeaderZero(number: String(arrivalDateArr[0]))
        let arrDay = addHeaderZero(number: String(arrivalDateArr[1]))
        let arrYear = arrivalDateArr[2]
        
        kayak_url = "https://www.kayak.com/flights/\(origin)-\(destAirportCode)/\(departYear)-\(departMonth)-\(departDay)/\(arrYear)-\(arrMonth)-\(arrDay)/1adults?sort=bestflight_a"
    }
    
    func generateOWKayakURL() {
        let departDateArr = departDate.split(separator: " ")
        
        let departMonth = addHeaderZero(number: String(departDateArr[0]))
        let departDay = addHeaderZero(number: String(departDateArr[1]))
        let departYear = departDateArr[2]
        
        kayak_url = "https://www.kayak.com/flights/\(origin)-\(destAirportCode)/\(departYear)-\(departMonth)-\(departDay)/1adults?sort=bestflight_a"
    }
    
    // MARK: - Helper Methods
    
    func addHeaderZero(number : String) -> String {
        return number.count == 1 ? "0" + number : number
    }
    
    func formatCityName(city : String) -> String {
        return city.replacingOccurrences(of: " ", with: "%20")
    }
    
    // MARK: - Database Methods
    
    func loadPlaces() {
        placeArray = realm.objects(Place.self) // gets all places from database
    }
    
    func createPlace() {
        let place = Place()
        place.airportCode = destAirportCode
        place.name = destination
        print("saving place!")
        savePlace(place: place)
    }
    
    func savePlace(place : Place) { // use filter to find if airport code exists in database already
        do {
            try realm.write {
                realm.add(place)
            }
        } catch {
            print("Error saving place to Realm \(error)")
        }
    }
    
    func createTrip() -> Trip {
        let trip = Trip()
        trip.arrivalDate = arrivalDate.replacingOccurrences(of: " ", with: "/")
        trip.departDate = departDate.replacingOccurrences(of: " ", with: "/")
        trip.destination = destination
        trip.origin = origin
        trip.expediaURL = expedia_url
        trip.kayakURL = kayak_url
        trip.tripType = tripTypeTextField.text!
        trip.destPlaceID = destPlaceID
        return trip
    }

}

