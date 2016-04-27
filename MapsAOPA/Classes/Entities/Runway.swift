//
//  Runway.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/16/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreData

enum RunwaySurface : Int
{
    case Water = 0
    case Soft
    case SoftDirt
    case SoftGravel
    case Hard
    case HardAsphalt
    case HardArmoredConcrete
    case HardConcrete
    case HardBituminusConcrete
    case HardMetal
    case HardCement
    
    init?(code: String?)
    {
        switch code ?? ""
        {
        case "water" : self = Water
            case "soft": self = Soft
            case "dirt": self = SoftDirt
            case "gravel": self = SoftGravel
            case "hard": self = Hard
            case "hard-asphalt": self = HardAsphalt
            case "hard-armored-concrete": self = HardArmoredConcrete
            case "hard-concrete": self = HardConcrete
            case "hard-bituminous-concrete": self = HardBituminusConcrete
            case "hard-metal": self = HardMetal
            case "hard-cement": self = HardCement
        default: return nil
        }
    }
}

enum RunwayLights : Int
{
    case None = 0
    case Always
    case OnRequest
    case PilotControlled
    
    init?(code: String?)
    {
        switch code ?? ""
        {
        case "1" : self = None
        case "2": self = Always
        case "3": self = OnRequest
        case "4": self = PilotControlled
        default: return nil
        }
    }
}

class Runway: NSManagedObject {
    
    convenience init?(dictionary: [String:AnyObject]?, inContext context: NSManagedObjectContext)
    {
        if let entity = NSEntityDescription.entityForName("Runway", inManagedObjectContext: context)
        {
            self.init(entity: entity, insertIntoManagedObjectContext: context)
            self.length = Int(dictionary?["length"] as? String ?? "")
            self.magneticCourse = dictionary?["kurs"] as? String
            self.surfaceType = RunwaySurface(code: dictionary?["pokr_code"] as? String)?.rawValue
            if let threshold1lat = Double(dictionary?["porog1_lat"] as? String ?? "")
            {
                if let threshold1lon = Double(dictionary?["porog1_lon"] as? String ?? "")
                {
                    if let threshold2lat = Double(dictionary?["porog2_lat"] as? String ?? "")
                    {
                        if let threshold2lon = Double(dictionary?["porog2_lon"] as? String ?? "")
                        {
                            let thresholds = [
                                [ "lat" : threshold1lat, "lon" : threshold1lon ],
                                [ "lat" : threshold2lat, "lon" : threshold2lon ]
                            ]
                            self.thresholds = thresholds
                        }
                    }
                }
            }
            self.width = Int(dictionary?["width"] as? String ?? "")
            self.lightsType = RunwayLights(code: dictionary?["lights_id"] as? String)?.rawValue
            self.title = dictionary?["name"] as? String
            self.trueCourse = dictionary?["kurs_ist"] as? String
            self.trafficPatterns = dictionary?["korobochka"] as? String
        }
        else
        {
            return nil
        }
    }
}
