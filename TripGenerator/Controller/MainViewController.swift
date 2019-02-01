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

class MainViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var tripTypeTextField: UITextField!
    
    let originList = ["Raleigh", "Boston", "New York City"]
    let tripTypeList = ["Round Trip", "One Way"]
    let cityList = ["Paris", "London", "Bangkok", "Singapore", "New York", "Kuala Lumpur", "Hong Kong", "Dubai", "Istanbul", "Rome", "Shanghai", "Los Angeles", "Las Vegas", "Miami", "Toronto", "Barcelona", "Dublin", "Amsterdam", "Moscow", "Cairo", "Prague", "Vienna", "Madrid", "San Francisco", "Vancouver", "Budapest", "Rio de Janeiro", "Berlin", "Tokyo", "Mexico City", "Buenos Aires", "St. Petersburg", "Seoul", "Athens", "Jerusalem", "Seattle", "Delhi", "Sydney", "Mumbai", "Munich", "Venice", "Florence", "Beijing", "Cape Town", "Washington D.C.", "Montreal", "Atlanta", "Boston", "Philadelphia", "Chicago", "San Diego", "Stockholm", "Cancun", "Warsaw", "Sharm el-Sheikh", "Dallas", "Ho Chi Minh", "Milan", "Oslo", "Lisbon", "Punta Cana", "Johannesburg", "Antalya", "Mecca", "Macau", "Pattaya", "Guangzhou", "Kiev", "Shenzhen", "Bucharest", "Taipei", "Orlando", "Brussels", "Chennai", "Marrakesh", "Phuket", "Edirne", "Bali", "Copenhagen", "Sao Paulo", "Agra", "Varna", "Riyadh", "Jakarta", "Auckland", "Honolulu", "Edinburgh", "Wellington", "New Orleans", "Petra", "Melbourne", "Luxor", "Hanoi", "Manila", "Houston", "Phnom Penh", "Zurich", "Lima", "Santiago", "Bogota"]
    
    // URL to get valid airport code
    let AIRPORT_URL = "https://iatacodes.org/api/v6/autocomplete?api_key=9e145a85-8a4f-4f41-aaf3-e807721840ff&query="
    var expedia_url = ""
    var kayak_url = ""
    var departDate = ""
    var arrivalDate = ""
    var origin = ""
    var destination = ""

    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { // number of columns
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { // number of rows
        if pickerView.tag == 1 {
            return originList.count
        } else {
            return tripTypeList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { // sets title for each row
        if pickerView.tag == 1 {
            return originList[row]
        } else {
            return tripTypeList[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) { // set text of textfield to row value
        if pickerView.tag == 1 {
            originTextField.text = originList[row]
            origin = originList[row]
        } else {
            tripTypeTextField.text = tripTypeList[row]
        }
    }
    
    @IBAction func generateTrip(_ sender: Any) {
        
        var number : Int = Int.random(in: 0 ..< cityList.count)
        destination = cityList[number]
        
        while (destination == originTextField.text!) {
            number = Int.random(in: 0 ..< cityList.count)
            destination = cityList[number]
        }
        
        Alamofire.request(AIRPORT_URL + destination, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                print("Got airport data!")
                let body : JSON = JSON(response.result.value!)
                let airportName = body["response"]["airports_by_cities"][0]["code"].stringValue
                print(self.destination)
                print(airportName)
                
                self.generateRandomDates()
                
                if (self.tripTypeTextField.text! == "Round Trip") {
                    self.generateRTExpediaURL(origin: self.origin, dest: self.destination, departDate: self.departDate, arrivalDate: self.arrivalDate)
                } else {
                    self.generateOWExpediaURL(origin: self.origin, dest: self.destination, departDate: self.departDate)
                }
                
                self.performSegue(withIdentifier: "goToTripPage", sender: self)
            } else {
                print("Error \(response.result.error!)")
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TripViewController
        print("performing segue")
        destinationVC.location = destination
    }
    
    func generateRandomDates() {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM dd y"
        let currentDate = dateFormatter.string(from: Date())
        print(currentDate)

        let dateArr = currentDate.split(separator: " ")

        let currMonth = Int(dateArr[0])
        let currDay = Int(dateArr[1])
        let currYear = Int(dateArr[2])
        var arrYear = 0

        print(currMonth!)
        print(currDay!)
        print(currYear!)

        let newMonth : Int = Int.random(in: currMonth! ... 12) // generate random month from current month to Dec
        var newDay : Int = 0

        if (newMonth == 1 || newMonth == 3 || newMonth == 5 || newMonth == 7 || newMonth == 8 || newMonth == 10 || newMonth == 12) {
            newDay = Int.random(in: 1 ... 31)
        } else if (newMonth == 4 ||  newMonth == 6 || newMonth == 9 || newMonth == 11) {
            newDay = Int.random(in: 1 ... 30)
        } else if (newMonth == 2) {
            newDay = Int.random(in: 1 ... 28)
        }
        
        print(newMonth)
        print(newDay)
        var arrMonth = 0
        var arrDay : Int = 0
        
        if (newMonth == 12) { // if depart month is december, add one to year and set arrival month to jan
            arrMonth = 1
            arrYear = currYear! + 1
        } else {
            arrMonth = newMonth + 1
            arrYear = currYear!
        }
        
        if (arrMonth == 1 || arrMonth == 3 || arrMonth == 5 || arrMonth == 7 || arrMonth == 8 || arrMonth == 10 || arrMonth == 12) {
            arrDay = Int.random(in: 1 ... 31)
        } else if (arrMonth == 4 ||  arrMonth == 6 || arrMonth == 9 || arrMonth == 11) {
            arrDay = Int.random(in: 1 ... 30)
        } else if (arrMonth == 2) {
            arrDay = Int.random(in: 1 ... 28)
        }
        
        print(arrMonth)
        print(arrDay)
        
        departDate = String(newMonth) + " " + String(newDay) + " " + String(currYear!)
        arrivalDate = String(arrMonth) + " " + String(arrDay) + " " + String(arrYear)
 
    }
    
    // MARK: - Generate URLS
    
    func generateRTExpediaURL(origin : String, dest : String, departDate : String, arrivalDate : String) {
        
        let departDateArr = departDate.split(separator: " ")
        let arrivalDateArr = arrivalDate.split(separator: " ")
        let departMonth = departDateArr[0]
        let departDay = departDateArr[1]
        let departYear = departDateArr[2]
        let arrMonth = arrivalDateArr[0]
        let arrDay = arrivalDateArr[1]
        let arrYear = arrivalDateArr[2]
        
        expedia_url = "https://www.expedia.com/Flights-Search?trip=roundtrip&leg1=from%3A\(origin)%2Cto%3A\(dest)%2Cdeparture%3A\(departMonth)%2F\(departDay)%2F\(departYear)TANYT&leg2=from%3A\(dest)%2Cto%3A\(origin)%%2Cdeparture%3A\(arrMonth)%2F\(arrDay)%2F\(arrYear)TANYT&passengers=adults%3A1%2Cchildren%3A0%2Cseniors%3A0%2Cinfantinlap%3AY&options=cabinclass%3Aeconomy&mode=search&origref=www.expedia.com"
    }
    
    func generateOWExpediaURL(origin : String, dest : String, departDate : String) {
        let departDateArr = departDate.split(separator: " ")
        let departMonth = departDateArr[0]
        let departDay = departDateArr[1]
        let departYear = departDateArr[2]
        expedia_url = "https://www.expedia.com/Flights-Search?trip=oneway&leg1=from%3A\(origin)%2Cto%3A\(dest)%2Cdeparture%3A\(departMonth)%2F\(departDay)%2F\(departYear)TANYT&passengers=adults%3A1%2Cchildren%3A0%2Cseniors%3A0%2Cinfantinlap%3AY&options=cabinclass%3Aeconomy&mode=search&origref=www.expedia.com"
    }

}

