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
    
    var chosenCity = ""

    let originList = ["Raleigh", "Boston", "New York City"]
    let tripTypeList = ["Round Trip", "One Way"]
    let cityList = ["Paris", "London", "Bangkok", "Singapore", "New York", "Kuala Lumpur", "Hong Kong", "Dubai", "Istanbul", "Rome", "Shanghai", "Los Angeles", "Las Vegas", "Miami", "Toronto", "Barcelona", "Dublin", "Amsterdam", "Moscow", "Cairo", "Prague", "Vienna", "Madrid", "San Francisco", "Vancouver", "Budapest", "Rio de Janeiro", "Berlin", "Tokyo", "Mexico City", "Buenos Aires", "St. Petersburg", "Seoul", "Athens", "Jerusalem", "Seattle", "Delhi", "Sydney", "Mumbai", "Munich", "Venice", "Florence", "Beijing", "Cape Town", "Washington D.C.", "Montreal", "Atlanta", "Boston", "Philadelphia", "Chicago", "San Diego", "Stockholm", "Cancun", "Warsaw", "Sharm el-Sheikh", "Dallas", "Ho Chi Minh", "Milan", "Oslo", "Libson", "Punta Cana", "Johannesburg", "Antalya", "Mecca", "Macau", "Pattaya", "Guangzhou", "Kiev", "Shenzhen", "Bucharest", "Taipei", "Orlando", "Brussels", "Chennai", "Marrakesh", "Phuket", "Edirne", "Bali", "Copenhagen", "Sao Paulo", "Agra", "Varna", "Riyadh", "Jakarta", "Auckland", "Honolulu", "Edinburgh", "Wellington", "New Orleans", "Petra", "Melbourne", "Luxor", "Hanoi", "Manila", "Houston", "Phnom Penh", "Zurich", "Lima", "Santiago", "Bogota"]
    
    // URL to get valid airport code
    let AIRPORT_URL = "https://iatacodes.org/api/v6/autocomplete?api_key=9e145a85-8a4f-4f41-aaf3-e807721840ff&query="

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
        } else {
            tripTypeTextField.text = tripTypeList[row]
        }
    }
    
    @IBAction func generateTrip(_ sender: Any) {
        
        var number : Int = Int.random(in: 0 ..< cityList.count)
        chosenCity = cityList[number]
        
        while (chosenCity == originTextField.text!) {
            number = Int.random(in: 0 ..< cityList.count)
            chosenCity = cityList[number]
        }
        
        Alamofire.request(AIRPORT_URL + chosenCity, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                print("Got airport data!")
                let body : JSON = JSON(response.result.value!)
                let airportName = body["response"]["airports_by_cities"][0]["code"].stringValue
                print(self.chosenCity)
                print(airportName)
                
                self.performSegue(withIdentifier: "goToTripPage", sender: self)
            } else {
                print("Error \(response.result.error!)")
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TripViewController
        print("doing this!!!")
        destinationVC.location = chosenCity
    }
    
}

