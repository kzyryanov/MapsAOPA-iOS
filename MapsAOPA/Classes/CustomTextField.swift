//
//  CustomTextField.swift
//  MapsAOPA
//
//  Created by Konstantin Zyrianov on 2019-06-12.
//  Copyright © 2019 Konstantin Zyrianov. All rights reserved.
//

import SwiftUI

struct CustomTextField : UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        
        private lazy var keyboardObserver: KeyboardObserver = {
            let keyboardHandler = BasicKeyboardHandler()
            let keyboardObserver = KeyboardObserver(handler: keyboardHandler)
            keyboardHandler.show = { [weak self] keyboardHeight in
                print("show")
                self?.keyboardHeight = keyboardHeight
            }
            keyboardHandler.hide = { [weak self] in
                print("hide")
                self?.keyboardHeight = 0.0
            }
            return keyboardObserver
        }()
        
        @Binding var text: String
        @Binding var keyboardHeight: CGFloat
        
        var didBecomeFirstResponder = false
        
        init(text: Binding<String>, keyboardHeight: Binding<CGFloat>) {
            $text = text
            $keyboardHeight = keyboardHeight
            super.init()
            self.keyboardObserver.activate()
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
        
    }
    
    @Binding var text: String
    @Binding var keyboardHeight: CGFloat
    var isFirstResponder: Bool = false
    
    func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        return textField
    }
    
    func makeCoordinator() -> CustomTextField.Coordinator {
        return Coordinator(text: $text, keyboardHeight: $keyboardHeight)
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}
