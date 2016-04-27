//
//  Database.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/15/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit
import CoreData
import ReactiveCocoa

class Database
{
    static let sharedDatabase = Database()
    
    private init() { }
    
    static func pointsPredicate(forRegion region: MKCoordinateRegion, withFilter filter: PointsFilter) -> NSPredicate
    {
        var format =
            "latitude >= \(region.center.latitude - region.span.latitudeDelta) AND " +
            "longitude >= \(region.center.longitude - region.span.longitudeDelta) AND " +
            "latitude <= \(region.center.latitude + region.span.latitudeDelta) AND " +
            "longitude <= \(region.center.longitude + region.span.longitudeDelta)"
        
        let airportsFormat : String
        var connection : String = "OR"
        switch filter.airportsState {
        case .All: airportsFormat = "(type = \(PointType.Airport.rawValue))"
        case .Active: airportsFormat = "(type = \(PointType.Airport.rawValue) AND active = 1)"
        case .None: airportsFormat = "(type != \(PointType.Airport.rawValue))"; connection = "AND"
        }
        
        let heliportsFormat : String
        switch filter.heliportsState {
        case .All: heliportsFormat = "(type = \(PointType.Heliport.rawValue))"
        case .Active: heliportsFormat = "(type = \(PointType.Heliport.rawValue) AND active = 1)"
        case .None: heliportsFormat = "(type != \(PointType.Heliport.rawValue))"; connection = "AND"
        }
        
        format += " AND (\(airportsFormat) \(connection) \(heliportsFormat))"

        return NSPredicate(format: format, argumentArray: nil)
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("MapsAOPA", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = Error.DataError.error()
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var backgroundManagedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext (context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
