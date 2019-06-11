//
//  MainViewController.swift
//  MapsAOPA
//
//  Created by Konstantin Zyrianov on 2019-06-07.
//  Copyright © 2019 Konstantin Zyrianov. All rights reserved.
//

import UIKit
import SwiftUI

struct MainViewController: UIViewControllerRepresentable {
    private var mainView = MainView()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MainViewController>) -> UIViewController {
        let viewController = UIHostingController(rootView: self.mainView)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<MainViewController>) {
        
    }
    
    class Coordinator: NSObject {
        var parent: MainViewController
        
        private let keyboardObserver: KeyboardObserver
        
        init(_ mainViewController: MainViewController) {
            self.parent = mainViewController
            let keyboardHandler = BasicKeyboardHandler()
            self.keyboardObserver = KeyboardObserver(handler: keyboardHandler)
            super.init()
            
            keyboardHandler.show = { [weak self] keyboardHeight in
                self?.parent.mainView.keyboardHeight = keyboardHeight
            }
            keyboardHandler.hide = { [weak self] in
                self?.parent.mainView.keyboardHeight = 0.0
            }
        }
        deinit {
            print("deinit")
        }
    }
}
