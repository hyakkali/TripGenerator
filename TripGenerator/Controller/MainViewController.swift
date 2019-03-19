//
//  ViewController.swift
//  TripGenerator
//
//  Created by Hemanth Yakkali on 1/30/19.
//  Copyright © 2019 Hemanth Yakkali. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase

class MainViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var placesArray = [Place]()
    
    @IBOutlet weak var originTextField: UITextField!
    
    @IBOutlet weak var greetingLabel: UILabel!
    
    @IBOutlet weak var tripTypeSegmentControl: UISegmentedControl!

    let originList = ["Raleigh", "Boston", "New York", "San Francisco"]
    
    var expedia_url = ""
    var kayak_url = ""
    var departDate = ""
    var arrivalDate = ""
    var origin = "Raleigh"
    var destination = ""
    var originCode = ""
    var destinationCode = ""
    var destPlaceID = ""
    var destinationCountry = ""
    var tripType = "Round Trip"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = FlatWhite()
        
        originTextField.useUnderline()
        
        setupPickerViews()
        displayGreeting()
        loadPlaces()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
        navBar.barTintColor = HexColor("#42eef4")
        navBar.tintColor = ContrastColorOf(HexColor("#42eef4")!, returnFlat: true)
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(HexColor("#42eef4")!, returnFlat: true)]
    }
    
    func setupPickerViews() {
        let originPickerView = UIPickerView()
        
        originPickerView.delegate = self
        
        originTextField.inputView = originPickerView
                
        originTextField.text = originList[0]
    }
    
    // MARK: - PickerView Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { // number of columns
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { // number of rows
        return originList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { // sets title for each row
        return originList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) { // set text of textfield to row value

        originTextField.text = originList[row]
        origin = originList[row]
        
        self.view.endEditing(true)
    }
    
    // MARK: - Buttons
    
    @IBAction func tripTypeChanged(_ sender: Any) {
        if (tripTypeSegmentControl.selectedSegmentIndex == 0) {
            tripType = "Round Trip"
        } else {
            tripType = "One Way"
        }
    }
    
    
    @IBAction func generateTrip(_ sender: Any) {
        
        let number : Int = Int.random(in: 0 ..< placesArray.count)
        destination = placesArray[number].name
        destinationCountry = placesArray[number].country
        destPlaceID = placesArray[number].placeID

        while (origin == destination) {
            let number : Int = Int.random(in: 0 ..< placesArray.count)
            destination = placesArray[number].name
            destinationCountry = placesArray[number].country
            destPlaceID = placesArray[number].placeID
        }
        
        originCode = getAirportCode(location: origin)
        destinationCode = placesArray[number].airportCode
        self.generateTripDetails()
    
    }
    
    @IBAction func tripsButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "goToFavTrips", sender: self)
    }
    
    func generateTripDetails() {
        self.generateRandomDates()
        
        if (self.tripType == "Round Trip") {
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
        
        expedia_url = "https://www.expedia.com/Flights-Search?trip=roundtrip&leg1=from:\(originCode),to:\(destinationCode),departure:\(departMonth)/\(departDay)/\(departYear)TANYT&leg2=from:\(destinationCode),to:\(originCode),departure:\(arrMonth)/\(arrDay)/\(arrYear)TANYT&passengers=adults:1,children:0,seniors:0,infantinlap:Y&options=cabinclass:economy&mode=search&origref=www.expedia.com"
    }
    
    func generateOWExpediaURL() {
        let departDateArr = departDate.split(separator: " ")
        
        let departMonth = departDateArr[0]
        let departDay = departDateArr[1]
        let departYear = departDateArr[2]
        
        expedia_url = "https://www.expedia.com/Flights-Search?trip=oneway&leg1=from:\(originCode),to:\(destinationCode),departure:\(departMonth)/\(departDay)/\(departYear)TANYT&passengers=adults:1,children:0,seniors:0,infantinlap:Y&options=cabinclass:economy&mode=search&origref=www.expedia.com"
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
        
        kayak_url = "https://www.kayak.com/flights/\(originCode)-\(destinationCode)/\(departYear)-\(departMonth)-\(departDay)/\(arrYear)-\(arrMonth)-\(arrDay)/1adults?sort=bestflight_a"
    }
    
    func generateOWKayakURL() {
        let departDateArr = departDate.split(separator: " ")
        
        let departMonth = addHeaderZero(number: String(departDateArr[0]))
        let departDay = addHeaderZero(number: String(departDateArr[1]))
        let departYear = departDateArr[2]
        
        kayak_url = "https://www.kayak.com/flights/\(originCode)-\(destinationCode)/\(departYear)-\(departMonth)-\(departDay)/1adults?sort=bestflight_a"
    }
    
    // MARK: - Helper Methods
    
    func addHeaderZero(number : String) -> String {
        return number.count == 1 ? "0" + number : number
    }
    
    func formatCityName(city : String) -> String {
        return city.replacingOccurrences(of: " ", with: "%20")
    }
    
    // MARK: - Database Methods
    
    func getAirportCode(location : String) -> String {
        var airportCode = ""
        
        if (location == "Raleigh") {
            return "RDU"
        }
        
        for place in placesArray {
            if (place.name == location) {
                airportCode = place.airportCode
            }
        }
        
        return airportCode
    }
    
    func loadPlaces() {
        let placesDB = Database.database().reference().child("places")
        
        placesDB.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary

            for place in value {
                let data = place.value as! NSDictionary
                let name = data["actualCityName"] as! String
                let airportCode = data["airportCode"] as! String
                let country = data["country"] as! String
                let placeID = data["placeID"] as! String
                
                let place = Place()
                place.name = name
                place.airportCode = airportCode
                place.country = country
                place.placeID = placeID
                
                self.placesArray.append(place)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }

    }
    
    func createTrip() -> Trip {
        let trip = Trip()
        trip.arrivalDate = arrivalDate.replacingOccurrences(of: " ", with: "/")
        trip.departDate = departDate.replacingOccurrences(of: " ", with: "/")
        trip.destination = destination
        trip.origin = origin
        trip.destinationCode = destinationCode
        trip.originCode = originCode
        trip.expediaURL = expedia_url
        trip.kayakURL = kayak_url
        trip.tripType = tripType
        trip.destPlaceID = destPlaceID
        trip.destinationCountry = destinationCountry
        return trip
    }

}

extension UITextField {
    
    func useUnderline() {
        
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.black.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width: self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
