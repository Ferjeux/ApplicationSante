//
//  AppDelegate.swift
//  ApplicationSante
//
//  Created by Admin on 20/06/2017.
//  Copyright © 2017 DTA. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let apiUrl = "http://10.1.0.100:3000/persons"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        refreshfromServer()
        return true
    }
    
    func importDataFromPlistIfNeeded(){
        
        //TODO  this function will be suppress when data download from server
        let didImportData = UserDefaults.standard.value(forKey: "didImportData") as? Bool ?? false
        if !didImportData {
            let fileUrl = Bundle.main.url(forResource: "names", withExtension: "plist")
            
            guard let url = fileUrl, let array = NSArray(contentsOfFile: url.path) else{
                return
            }
            //let array = NSArray(contentsOfFile: url.path)
            for dict in array{
                if let dictionnary = dict as? [String:Any]{
                    let firstname = dictionnary["name"] as? String ?? "ERROR"
                    let lastname = dictionnary["lastname"] as? String ?? "ERROR"
                    let data = PersonneData(entity: PersonneData.entity(), insertInto: persistentContainer.viewContext)
                    data.firstname = firstname
                    data.lastname = lastname
                }
                
                do{
                    try persistentContainer.viewContext.save()
                }
                catch{
                    print(error)
                }
            }
            UserDefaults.standard.set(true, forKey: "didImportData")
        }
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
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
}

extension UIViewController{
    var persistentContainer : NSPersistentContainer{
        get {
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            return appdelegate.persistentContainer
        }
    }
}

