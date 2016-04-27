//
//  Point.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/16/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreData

enum PointType : Int
{
    case Airport = 0
    case Heliport
    
    init?(type: String?)
    {
        switch type ?? ""
        {
        case "airport": self = Airport
        case "vert": self = Heliport
        default: return nil
        }
        
    }
}

enum PointBelongs : Int
{
    case Civil = 0
    case Military
    case General
    case FSS
    case DOSAAF
    case Experimantal
    
    init?(string: String?)
    {
        switch string ?? ""
        {
        case "ГА": self = Civil
        case "МО": self = Military
        case "АОН": self = General
        case "ФСБ": self = FSS
        case "ДОСААФ": self = DOSAAF
        case "ЭА": self = Experimantal
        default: return nil
        }
    }
    
    func isMilitary() -> Bool
    {
        switch self
        {
        case .Military, .FSS, .Experimantal: return true
        default: return false
        }
    }
}

class Point: NSManagedObject {
    func isServiced() -> Bool
    {
        return self.fuel?.count ?? 0 > 0
    }
    
    class func point(fromDictionary dictionary: [String:AnyObject]?, inContext context: NSManagedObjectContext) -> Point?
    {
        if let index = dictionary?["index"] as? String
        {
            
            let currentPointRequest = NSFetchRequest(entityName: "Point")
            currentPointRequest.predicate = NSPredicate(format: "index == %@", index)
            let point : Point
            do
            {
                if let currentPoint = try context.executeFetchRequest(currentPointRequest).first as? NSManagedObject
                {
                    context.deleteObject(currentPoint)
                }
                if let entity = NSEntityDescription.entityForName("Point", inManagedObjectContext: context)
                {
                    point = Point(entity: entity, insertIntoManagedObjectContext: context)
                }
                else
                {
                    return nil
                }
            }
            catch
            {
                return nil
            }
            point.index = dictionary?["index"] as? String
            point.indexRu = dictionary?["index_ru"] as? String
            point.type = PointType(type: dictionary?["type"] as? String)?.rawValue
            point.active = Int(dictionary?["active"] as? String ?? "0")
            point.belongs = PointBelongs(string: dictionary?["belongs"] as? String)?.rawValue
            point.latitude = Double(dictionary?["lat"] as? String ?? "0.0")
            point.longitude = Double(dictionary?["lon"] as? String ?? "0.0")
            point.title = dictionary?["name"] as? String
            point.titleRu = dictionary?["name_ru"] as? String
            point.details = PointDetails(dictionary: dictionary, inContext: context)
            let runwayDicts = dictionary?["vpp"] as? [[String:AnyObject]] ?? []
            for runwayDict in runwayDicts
            {
                let runway = Runway(dictionary: runwayDict, inContext: context)
                runway?.point = point
            }
            let fuelDicts = dictionary?["fuel"] as? [[String:AnyObject]] ?? []
            for fuelDict in fuelDicts
            {
                if let type = FuelType(type: fuelDict["type_id"] as? String ?? "")
                {
                    do
                    {
                        let request = NSFetchRequest(entityName: "Fuel")
                        request.predicate = NSPredicate(format: "type == %d", type.rawValue)
                        let fuels = try context.executeFetchRequest(request)
                        let fuel = fuels.first as? Fuel ?? Fuel(dictionary: fuelDict, inContext: context)
                        if let existType = fuelDict["exists_id"] as? String where existType == "1"
                        {
                            let points = fuel?.points?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
                            points.addObject(point)
                            fuel?.points = points
                        }
                        else
                        {
                            let points = fuel?.pointsOnRequest?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
                            points.addObject(point)
                            fuel?.pointsOnRequest = points
                        }
                    }
                    catch {
                        fatalError("Failed to fetch fuel")
                    }
                }
            }
            return point
        }
        else
        {
            return nil   
        }
    }
}
