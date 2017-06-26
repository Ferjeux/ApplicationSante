//
//  DetailViewController.swift
//  ApplicationSante
//
//  Created by Admin on 20/06/2017.
//  Copyright © 2017 DTA. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    
    var patient : PersonneData!
    var ondeletePatient: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = patient.displayFullName()
        let  button = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePatientController))
        self.navigationItem.rightBarButtonItem = button
        nameLabel.text = patient.displayFullNameWithGender()
        
        avatarImage.image = UIImage(named:"")
        
        let task = URLSession.shared.dataTask(with: URL(string: patient.picturUrl!)!){ (data, response, error) in
            DispatchQueue.main.async {
                print(Thread.isMainThread)
                if let data = data, let image = UIImage(data: data){
                    self.avatarImage.image = image
                }
            }
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    func deletePatientController(){
        let alertController = UIAlertController(title: "Validation?", message: "Etes vous sur de vouloir supprimer ce patient?", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "Non", style: .cancel){
            action in
        }
        alertController.addAction(noAction)
        
        let yesAction = UIAlertAction(title: "Oui", style: .destructive){ action in self.ondeletePatient?()
            
        }
        alertController.addAction(yesAction)
        
        self.present(alertController, animated: true){
            //nothing
        }
    }
}
