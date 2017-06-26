//
//  PatientTableViewController.swift
//  ApplicationSante
//
//  Created by Admin on 20/06/2017.
//  Copyright © 2017 DTA. All rights reserved.
//

import UIKit
import CoreData

class PatientTableViewController: UITableViewController {
       
    var fetchedResultController : NSFetchedResultsController<PersonneData>!
    let apiUrl = "http://10.1.0.100:3000/persons"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest<PersonneData>(entityName: "PersonneData")
        let sort = NSSortDescriptor(key: "lastname", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: "personCache")
        fetchedResultController.delegate = self
        try! fetchedResultController.performFetch()
        
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showCreateViewController))
        let settingButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showSettingController))

        self.navigationItem.rightBarButtonItem = button
        self.navigationItem.leftBarButtonItem = settingButton
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshfromServer()
    }
    
    func showSettingController(){
        let controllerSetting = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        self.present(controllerSetting, animated: true)
    }
    
    //sending data to DetailViewcontroller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let detailController = segue.destination as? DetailViewController{
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else{
                return
            }
            detailController.ondeletePatient = {
                let patient = self.fetchedResultController.object(at: selectedIndexPath)
                //self.persistentContainer.viewContext.delete(patient)
                //try? self.persistentContainer.viewContext.save()
                //self.tableView.reloadData()
                
                // insert delete on Web
                
                let deleteUrl = (self.apiUrl + "/" + String(patient.serverId))
                var request = URLRequest(url: URL(string: deleteUrl)!)
                request.httpMethod = "DELETE"
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    
                }
                task.resume()
                
                self.navigationController?.popViewController(animated: true)
            }
        
            
            detailController.patient = fetchedResultController.object(at: selectedIndexPath)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetchedResultController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "patientCell", for: indexPath)
        cell.textLabel?.text = fetchedResultController.object(at: indexPath).displayFullName()
        return cell
    }
    
    func showCreateViewController(){
        let controller = CreatePatientController(nibName: "CreatePatientController", bundle: nil)
        controller.delegate = self
        self.present(controller, animated: true)
        
    }
    
    func refreshfromServer(){
        let url = URL(string: apiUrl)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else{
                return
            }
            
            let dictionnary = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            guard let jsonDict = dictionnary as? [[String : Any]] else {
                return
            }
            self.updateFromJsonData(json: jsonDict)
        }
        
        task.resume()
    }
    
    func deleteAllpatient(){
        let fetchRequest = NSFetchRequest<PersonneData>(entityName: "PersonneData")
        let sort = NSSortDescriptor(key: "lastname", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        let persons = try! self.persistentContainer.viewContext.fetch(fetchRequest)
        for person in persons{
            self.persistentContainer.viewContext.delete(person)
        }
        try! self.persistentContainer.viewContext.save()
    }
    
    func updateFromJsonData(json: [[String : Any]]){
        self.deleteAllpatient()
        for person in json{
            let data = PersonneData(entity: PersonneData.entity(), insertInto: persistentContainer.viewContext)
            data.firstname = person["surname"] as? String ?? "Error"
            data.lastname = person["lastname"] as? String ?? "Error"
            data.serverId = person["id"] as? Int64 ?? -1
            data.picturUrl = person["pictureUrl"] as? String ?? "Error"
        }
        do{
            try persistentContainer.viewContext.save()
        }
        catch{
            print(error)
        }
    }
}

extension PatientTableViewController : CreatePatientDelegate {
    func patientCreated(person: PersonneData) {
        //TODO : Display alert : patient is created
        self.presentedViewController?.dismiss(animated: false, completion: nil)
        self.tableView.reloadData()
    }
}

extension PatientTableViewController : NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
}


