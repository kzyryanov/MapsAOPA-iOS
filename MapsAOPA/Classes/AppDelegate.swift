//
//  AppDelegate.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/14/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
        Database.sharedDatabase.saveContext(Database.sharedDatabase.managedObjectContext)
    }
}

