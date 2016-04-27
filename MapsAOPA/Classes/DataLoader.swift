//
//  DataLoader.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/15/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import AFNetworking
import ReactiveCocoa

class DataLoader
{
    private static let serverAddress : String = "http://maps.aopa.ru"
    private static let dataPath : String = "/export/exportFormRequest/?exportType=standart&exportAll%5B%5D=airport&exportAll%5B%5D=vert&exportFormat=xml"
    private static let imagesPath : String = "/static/pointImages/"
    
    static var apiKey : String? {
        get {
            return Config.networkConfig[AppKeys.ApiKey.rawValue] as? String ?? NSUserDefaults.standardUserDefaults().stringForKey(AppKeys.ApiKey.rawValue)
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: AppKeys.ApiKey.rawValue)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    static let sharedLoader : DataLoader = DataLoader()
    
    private lazy var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    private init() { }
    
    func signalForAirfieldsData() -> SignalProducer<NSURL, NSError>
    {
        return SignalProducer({
            observer, disposable in
            if let apiKey = DataLoader.apiKey where apiKey.length > 0
            {
                if let url = NSBundle.mainBundle().URLForResource("aopa-points-export", withExtension: "xml")
                {
//                    if let parser = NSXMLParser(contentsOfURL: url)
//                    {
                        observer.sendNext(url)
                        observer.sendCompleted()
                        return
//                    }
                }
                observer.sendFailed(Error.FileNotFound.error())
                /*
                let url = NSURL(string: "\(DataLoader.serverAddress)\(DataLoader.dataPath)&api_key=\(apiKey)")!
                self.session.downloadTaskWithRequest(NSURLRequest(URL: url), completionHandler: { (fileURL, response, error) in
                    if let error = error
                    {
                        observer.sendFailed(error)
                    }
                    else if let fileURL = fileURL
                    {
                        observer.sendNext((NSXMLParser(contentsOfURL: fileURL), 1.0))
                        observer.sendCompleted()
                    }
                    else
                    {
                        observer.sendFailed(Error.FileNotFound.error())
                    }
                }).resume()
                */
            }
            else
            {
                observer.sendFailed(Error.ApiKeyRequired.error())
            }
        })
    }
}
