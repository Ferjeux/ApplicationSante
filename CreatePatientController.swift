//
//  CreatePatientController.swift
//  ApplicationSante
//
//  Created by Admin on 20/06/2017.
//  Copyright © 2017 DTA. All rights reserved.
//

import UIKit

protocol CreatePatientDelegate : AnyObject {
    
    func patientCreated(person : PersonneData)
}

class CreatePatientController: UIViewController {
    
    @IBOutlet weak var waitProgressBar: UIProgressView!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addPatientButton: UIButton!
    @IBOutlet weak var genderSegmentControl: UISegmentedControl!
    //apiURl must be send
    let apiUrl = "http://10.1.0.100:3000/persons"
    weak var delegate : CreatePatientDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        waitProgressBar.setProgress(0, animated: false)
        waitProgressBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPatient(_ sender: UIButton) {
        
        if (nameTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces) != "" && firstnameTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces) != ""){
            
            waitProgressBar.isHidden = false
            addPatientButton.isHidden = true
            
            var json = [String:String]()
            json["surname"] = self.firstnameTextField.text ?? "Unknown"
            json["lastname"] = self.nameTextField.text ?? "Unknown"
            json["pictureUrl"] = "https://orig13.deviantart.net/5649/f/2009/246/1/5/defender_dwarf_3_by_serg_natos.jpg"
            
            var request = URLRequest(url: URL(string:self.apiUrl)!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    let jsonDict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any]
                    guard let dict = jsonDict as? [String : Any] else {
                        return
                    }
                    let person = PersonneData(entity: PersonneData.entity(), insertInto: self.persistentContainer.viewContext)
                    
                    person.lastname = dict["lastname"] as? String
                    person.firstname = dict["surname"] as? String
                    person.picturUrl = dict["pictureUrl"] as? String
                    person.serverId = Int64(dict["id"] as? Int ?? 0)
                    
                    DispatchQueue.main.async{
                        try? self.persistentContainer.viewContext.save()
                        self.delegate?.patientCreated(person: person)
                        self.delegate?.patientCreated(person: person)
                    }
                }
            }
            task.resume()
        }
        else{
            //TODO : create function error textfield
            if nameTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces) == "" {
                nameTextField.layer.borderWidth = 1.0
                nameTextField.layer.cornerRadius = 4
                nameTextField.layer.borderColor = UIColor.red.cgColor
            }
            if firstnameTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces) == "" {
                firstnameTextField.layer.borderWidth = 1.0
                firstnameTextField.layer.cornerRadius = 4
                firstnameTextField.layer.borderColor = UIColor.red.cgColor
            }
        }
    }
    @IBAction func nameEdit(_ sender: Any) {
        nameTextField.layer.borderWidth = 1.0
        nameTextField.layer.cornerRadius = 4
        nameTextField.layer.borderColor = UIColor.white.cgColor
    }
}
