//
//  SearchBar.swift
//  Popflash
//
//  Created by Seb Vidal on 10/06/2021.
//

import SwiftUI

struct SearchBar: View {

    @State var placeholder: String
    @Binding var query: String
    @State var isEditing = false
    @FocusState var isFocused: Bool
    
    @AppStorage("settings.tint") var tint: Int = 1

    var body: some View {

        HStack(spacing: 0) {
            
            ZStack(alignment: .leading) {

                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .frame(height: 36)
                    .foregroundColor(Color("Search_Bar"))
                    .animation(.easeInOut(duration: 0.25), value: [isEditing, isFocused])
                
                HStack(spacing: 0) {
                    
                    Image(systemName: "magnifyingglass")
                        .padding(.leading, 6)
                    
                    Text(placeholder)
                        .padding(.leading, 4)
                        .opacity(query.isEmpty ? 1 : 0)
                    
                    Spacer()
                    
                    if !query.isEmpty {
                        
                        Button {
                            
                            clear()
                            
                        } label: {
                            
                            Image(systemName: "multiply.circle.fill")
                            
                        }
                        .padding(.trailing, 6)
                        
                    }
                    
                }
                .foregroundColor(Color("Search_Bar_Icons"))
                
                TextField("", text: $query)
                    .padding(.leading, 31)
                    .padding(.trailing, query.isEmpty ? 0 : 31)
                    .animation(.easeInOut(duration: 0.25), value: [isEditing, isFocused])
                    .submitLabel(.search)
                    .focused($isFocused)
                    .onChange(of: isFocused, perform: { focused in
                        
                        if focused {
                            
                            isEditing = true
                            
                        }
                                                
                    })

            }
            
            if isEditing {
                
                Button("Cancel") {
                    
                    cancel()
                    
                }
                .padding(.leading, 12)
                .foregroundColor(TintColour.colour(withID: tint))
                .transition(AnyTransition.move(edge: .trailing).combined(with: .opacity).animation(.easeInOut(duration: 0.25)))
                .animation(.easeInOut(duration: 0.25))

            }
            
        }
        .buttonStyle(.borderless)

    }
    
    func clear() {
        
        query = ""
        isFocused = true
        
    }
    
    func cancel() {
        
        query = ""
        isFocused = false
        isEditing = false
        
    }

}

struct CancelButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration
            .label
            .opacity(configuration.isPressed ? 0.2 : 1)
        
    }
    
}
