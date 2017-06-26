//
//  Patient.swift
//  ApplicationSante
//
//  Created by Admin on 20/06/2017.
//  Copyright © 2017 DTA. All rights reserved.
//

import Foundation

extension PersonneData {
    func displayFullName() -> String{
        return "\(firstname!) \(lastname!)"
    }
    
    func displayFullNameWithGender() -> String{
        var particule : String
        particule = "M."
        return ("\(particule) \(self.displayFullName())")
        
    }
}


