//
//  ViewController.swift
//  ValidateTextField
//
//  Created by 오민호 on 2017. 12. 16..
//  Copyright © 2017년 오민호. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: ValidateTextField!
    @IBOutlet weak var phoneTextField: ValidateTextField!
    @IBOutlet weak var plainTextField: ValidateTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        emailTextField.validateType = .email(customPattern: nil)
        phoneTextField.validateType = .phone(customPattern: nil)
        plainTextField.validateType = .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

