//
//  LoginViewController.swift
//  TripGenerator
//
//  Created by Hemanth Yakkali on 3/4/19.
//  Copyright © 2019 Hemanth Yakkali. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if error != nil {
                print(error!)
            } else {
                print("Login successful!")
                self.performSegue(withIdentifier: "goToMain", sender: self)
            }
        }
    }
    
}
