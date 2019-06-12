//
//  MainView.swift
//  MapsAOPA
//
//  Created by Konstantin Zyrianov on 2019-06-05.
//  Copyright © 2019 Konstantin Zyrianov. All rights reserved.
//

import SwiftUI

struct MainView : View {
    @State private var searchText: String = ""
    @State private var showSearchField: Bool = false
    @State private var keyboardHeight: CGFloat = 0.0
    
    var body: some View {
        ZStack(alignment: .trailing) {
            MapView().edgesIgnoringSafeArea([.top, .bottom])
            VStack {
                Spacer()
                ZStack {
                    Color.white
                        .cornerRadius(25.0)
                        .shadow(color: Color.black, radius: 3.0, x: 0.0, y: 2.0)
                    HStack {
                        if showSearchField {
                            CustomTextField(text: $searchText, keyboardHeight: $keyboardHeight, isFirstResponder: showSearchField).relativeHeight(0.0).padding()
                        }
                        Button(action: {
                            withAnimation(.basic(duration: 0.25, curve: .easeInOut)) {
                                self.showSearchField.toggle()
                                if !self.showSearchField {
                                self.keyboardHeight = 0.0
                                }
                            }
                        }) {
                            Text("🔎")
                            }.frame(width: 50, height: 50, alignment: .center).layoutPriority(1.0)
                    }.layoutPriority(1.0)
                    }.offset(x: 0.0, y: -keyboardHeight).padding()
                }.edgesIgnoringSafeArea(showSearchField ? [ .bottom ] : [])
        }
    }
}

#if DEBUG
struct MainView_Previews : PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
#endif
