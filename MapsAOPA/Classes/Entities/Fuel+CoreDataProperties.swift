//
//  Fuel+CoreDataProperties.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/21/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Fuel {

    @NSManaged var type: NSNumber?
    @NSManaged var points: NSSet?
    @NSManaged var pointsOnRequest: NSSet?

}
