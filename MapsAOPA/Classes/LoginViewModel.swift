//
//  LoginViewModel.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/16/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import ReactiveCocoa
import CoreData

enum LoginState
{
    case None, Loading, Processing(Int), Completed
    
    func stateDescription() -> String
    {
        switch self
        {
        case .None: return ""
        case .Loading: return "title_loading".localized()
        case .Processing(let value): return "\("title_processing".localized()) (\(value))"
        case .Completed: return "title_completed".localized()
        }
    }
}

class LoginViewModel
{
    let progress = MutableProperty<Float>(0.0)
    let state = MutableProperty<LoginState>(.None)
    
    init() {
        
    }

    func loadSignal() -> SignalProducer<Void, NSError>
    {
        return DataLoader.sharedLoader.signalForAirfieldsData()
            .on(started: { self.progress.value = 0; self.state.value = .Loading },
                completed: { self.state.value = .Processing(0); self.progress.value = 0.5 })
            .flatMap(.Latest, transform: { value -> SignalProducer<[String:AnyObject], NSError> in
                let timeInterval = NSDate().timeIntervalSinceDate(Config.lastUpdate)
                if  Config.weekTimeInterval < timeInterval
                {
                    return self.elementsFromSignal(NSXMLParser(contentsOfURL: value)!.parserSignal()).on(next: {
                            Point.point(fromDictionary: $0, inContext: Database.sharedDatabase.backgroundManagedObjectContext)
                            Database.sharedDatabase.saveContext(Database.sharedDatabase.backgroundManagedObjectContext)
                        }, completed: {
                        Config.lastUpdate = NSDate()
                        Database.sharedDatabase.saveContext(Database.sharedDatabase.backgroundManagedObjectContext)
                    }).startOn(QueueScheduler(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))).observeOn(UIScheduler())
                }
                else
                {
                    return SignalProducer { observer, disposable in observer.sendCompleted() }
                }
            })
            .on(completed: {
                    self.state.value = .Completed;
                    self.progress.value = 1.0;
                },
                next: { point in
                    var error : NSError? = nil
                    let fetchRequest = NSFetchRequest(entityName: "Point")
                    let count = Database.sharedDatabase.managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
                    self.state.value = .Processing(count)
            })
            .map({ _ in  })
    }
    
    private func elementsFromSignal(signal: SignalProducer<(element: String, state: XMLParseState, characters: String?), NSError>) -> SignalProducer<[String:AnyObject], NSError>
    {
        return SignalProducer {
            observer, disposable in
            
            var stack : NSMutableArray = NSMutableArray()
            let arrayElements = Set(arrayLiteral: "vpp", "contact", "freq", "fuel")
            
            signal.filter({ $0.element != "points" }).on(failed: { observer.sendFailed($0) },
                completed: { observer.sendCompleted() },
                next: { (element, state, characters) in
                    switch state
                    {
                    case .Start:
                        let elementObject : AnyObject
                        if arrayElements.contains(element)
                        {
                            elementObject = NSMutableArray()
                        }
                        else
                        {
                            elementObject = NSMutableDictionary()
                        }
                        
                        if let parent = stack.lastObject
                        {
                            if parent is NSMutableDictionary
                            {
                                (parent as! NSMutableDictionary)[element] = elementObject
                            }
                            else if parent is NSMutableArray
                            {
                                (parent as! NSMutableArray).addObject(elementObject)
                            }
                        }
                        stack.addObject(elementObject)
                    case .End where element == "point":
                        if let point = stack.lastObject as? [String:AnyObject]
                        {
                            observer.sendNext(point)
                        }
                        stack = NSMutableArray()
                    case .End:
                        stack.removeLastObject()
                        if let parent = stack.lastObject as? NSMutableDictionary
                        {
                            if let text = characters
                            {
                                parent[element] = text
                            }
                            else if !arrayElements.contains(element)
                            {
                                parent.removeObjectForKey(element)
                            }
                        }
                    }
            }).start()
        }
    }
}
