//
//  RegistrationViewController.swift
//  TripGenerator
//
//  Created by Hemanth Yakkali on 3/4/19.
//  Copyright © 2019 Hemanth Yakkali. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error != nil {
                print(error!)
            } else {
                // success
                print("Success!")
                self.performSegue(withIdentifier: "goToMain", sender: self)
            }
        }
    }

}
