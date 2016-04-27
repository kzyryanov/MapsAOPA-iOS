//
//  Error.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/15/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//


enum Error : Int
{
    static let domain = "com.example.MapsAOPA"
    
    case NoError = 0
    case ApiKeyRequired
    case FileNotFound
    case DataError
    
    func error() -> NSError
    {
        return NSError(domain: Error.domain, code: self.rawValue, userInfo: nil)
    }
}