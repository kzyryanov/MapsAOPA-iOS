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
    
    var keyboardHeight: CGFloat = 0.0
    
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
                            TextField($searchText, placeholder: Text("Search"), onEditingChanged: { isEditing in
                                print(isEditing)
                                print(self.searchText)
                            }, onCommit: {
                                print(self.searchText)
                            }).disabled(!showSearchField).clipped().padding()
                        }
                        Button(action: {
                            withAnimation(.basic(duration: 0.25, curve: .easeInOut)) {
                                self.showSearchField.toggle()
                            }
                        }) {
                            Text("🔎")
                            }.frame(width: 50, height: 50, alignment: .center)
                    }.layoutPriority(1.0)
                }.padding()
                
                if showSearchField {
                    Spacer(minLength: keyboardHeight)
                }
            }
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
