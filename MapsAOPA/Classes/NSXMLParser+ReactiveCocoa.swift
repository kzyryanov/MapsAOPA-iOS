//
//  NSXMLParser+ReactiveCocoa.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/16/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import ReactiveCocoa

enum XMLParseState
{
    case Start, End
}

extension NSXMLParser
{
    private class XMLParserDelegate : NSObject, NSXMLParserDelegate, Disposable
    {
        var disposed : Bool = false
        var observer : Observer<(element: String, state: XMLParseState, characters: String?), NSError>
        var element : String?
        var characters : String?
        
        init(observer: Observer<(element: String, state: XMLParseState, characters: String?), NSError>)
        {
            self.observer = observer
        }
        
        func dispose() {
            observer.sendCompleted()
        }
        
        // MARK : NSXMLParserDelegate
        
        @objc private func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
            self.element = elementName
            self.characters = nil
            self.observer.sendNext((elementName, .Start, self.characters))
        }
        
        @objc private func parser(parser: NSXMLParser, foundCharacters string: String) {
            if self.characters == nil
            {
                self.characters = ""
            }
            self.characters?.appendContentsOf(string)
        }
        
        @objc private func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            self.observer.sendNext((elementName, .End, self.characters))
            if self.element == elementName
            {
                self.characters = nil
            }
        }
        
        @objc private func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
            self.observer.sendFailed(parseError)
        }
        
        @objc private func parser(parser: NSXMLParser, validationErrorOccurred validationError: NSError) {
            self.observer.sendFailed(validationError)
        }
        
        @objc private func parserDidEndDocument(parser: NSXMLParser) {
            self.observer.sendCompleted()
        }
    }
    
    func parserSignal() -> SignalProducer<(element: String, state: XMLParseState, characters: String?), NSError>
    {
        return SignalProducer {
            observer, disposable in
            
            let delegate = XMLParserDelegate(observer: observer)
            self.delegate = delegate
            self.parse()
            disposable.addDisposable(delegate)
        }
    }
}
