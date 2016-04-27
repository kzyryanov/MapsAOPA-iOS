//
//  Config.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/15/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

enum AppKeys : String
{
    case ApiKey = "api_key"
    case LastUpdate = "last_update"
    case LastRegion = "last_region"
    case PointsFilter = "points_filter"
}

enum PointsFilterState : Int
{
    case None
    case Active
    case All
}

struct PointsFilter
{
    var airportsState : PointsFilterState
    var heliportsState : PointsFilterState
}

class Config
{
    static let weekTimeInterval : NSTimeInterval = 7 * 24 * 60 * 60
    
    static let networkConfig : [String:AnyObject] = NSDictionary(contentsOfFile:NSBundle.mainBundle().pathForResource("NetworkConfig", ofType: "plist") ?? "") as? [String:AnyObject] ?? [:]
    
    static var pointsFilter : PointsFilter = {
        let filter = NSUserDefaults.standardUserDefaults().objectForKey(AppKeys.PointsFilter.rawValue) as? [String:AnyObject]
        return PointsFilter(airportsState:
            PointsFilterState(rawValue: filter?["a_state"] as? Int ?? PointsFilterState.Active.rawValue) ?? .Active,
                            heliportsState:
            PointsFilterState(rawValue: filter?["h_state"] as? Int ?? PointsFilterState.None.rawValue) ?? .None)
    }()
    {
        didSet {
            let filter = [
                "a_state" : pointsFilter.airportsState.rawValue,
                "h_state" : pointsFilter.heliportsState.rawValue
            ]
            NSUserDefaults.standardUserDefaults().setObject(filter, forKey: AppKeys.PointsFilter.rawValue)
        }
    }
    
    static var lastUpdate : NSDate = NSDate(timeIntervalSince1970: NSUserDefaults.standardUserDefaults().doubleForKey(AppKeys.LastUpdate.rawValue))
    {
        didSet {
            
            NSUserDefaults.standardUserDefaults().setDouble(lastUpdate.timeIntervalSince1970, forKey: AppKeys.LastUpdate.rawValue)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    static let defaultCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 55.75, longitude: 37.616667)
    
    static func mapRegion(withDefaultCoordinate coordinate: CLLocationCoordinate2D) -> MKCoordinateRegion
    {
        if let regionDict = NSUserDefaults.standardUserDefaults().objectForKey(AppKeys.LastRegion.rawValue) as? [String:Double]
        {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: regionDict["lat"] ?? 0, longitude: regionDict["lon"] ?? 0),
                                      span: MKCoordinateSpan(latitudeDelta: regionDict["lat_delta"] ?? 0.2, longitudeDelta: regionDict["lon_delta"] ?? 0.2))
        }
        return MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    }
    
    static func saveRegion(region: MKCoordinateRegion)
    {
        let regionDict = [
            "lat" : region.center.latitude,
            "lon" : region.center.longitude,
            "lat_delta" : region.span.latitudeDelta,
            "lon_delta" : region.span.longitudeDelta
        ]
        NSUserDefaults.standardUserDefaults().setObject(regionDict, forKey: AppKeys.LastRegion.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
