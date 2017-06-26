//
//  SettingsViewController.swift
//  ApplicationSante
//
//  Created by Admin on 21/06/2017.
//  Copyright © 2017 DTA. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var choice: UISegmentedControl!
    
    let preferenceChoice : String = "preferenceChoice"
    var preference = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let value = UserDefaults.standard.value(forKey: preferenceChoice){
            choice.selectedSegmentIndex = value as! Int
        }
        else{
            choice.selectedSegmentIndex = 1
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if choice.selectedSegmentIndex == 0 {
            preference = 0
        }
        else{
            preference = 1
        }
        UserDefaults.standard.set(preference, forKey: preferenceChoice)
        self.dismiss(animated: true, completion: nil)
    }
}
