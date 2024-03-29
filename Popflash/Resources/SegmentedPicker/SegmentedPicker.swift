//
//  SegmentedPicker.swift
//  Popflash
//
//  Created by Seb Vidal on 22/06/2021.
//

import SwiftUI

struct SegmentedPicker: View {
    
    var items: [String]
    var itemStyle: SegmentedPickerItemStyle = .text
    var pickerStyle: SegmentedPickerStyle = .default
    var defaultsKey: String
    var wildcard: String = "All"
    
    @Binding var selectedItems: [String]
    
    @AppStorage("settings.tint") var tint: Int = 1
    
    var body: some View {
        
        HStack(spacing: 2) {
            
            Button {
                
                selectedItems = [wildcard]
                
            } label: {
                
                Rectangle()
                    .foregroundStyle(isSelected(item: wildcard) ? TintColour.colour(withID: tint) : Color("Picker_Background"))
                    .overlay(Text(wildcard).font(.subheadline).foregroundStyle(isSelected(item: wildcard) ? Color("Selected") : Color("Unselected")))
                
            }
            
            ForEach(items, id: \.self) { item in
                
                Button {

                    segmentAction(item: item)

                } label: {
                    
                    Rectangle()
                        .foregroundStyle(isSelected(item: item) ? TintColour.colour(withID: tint) : Color("Picker_Background"))
                        .overlay {
                            
                            switch itemStyle {
                            case .image:
                                
                                Image("\(item)_Icon")
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 35)
                                    .font(.subheadline)
                                    .foregroundStyle(isSelected(item: item) ? Color("Selected") : Color("Unselected"))
                                
                            case .text:
                                
                                Text(item)
                                    .font(.subheadline)
                                    .foregroundStyle(isSelected(item: item) ? Color("Selected") : Color("Unselected"))
                                
                            }
                            
                        }
                    
                }
                
            }
            
        }
        .frame(height: 60)
        .buttonStyle(.plain)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        
    }
    
    func isSelected(item: String) -> Bool {
        
        return selectedItems.contains(item)
        
    }
    
    func segmentAction(item: String) {
        
        switch pickerStyle {
        case .default:
            
            if selectedItems.contains(item) {
                
                if let index = selectedItems.firstIndex(of: item) {
                    
                    selectedItems.remove(at: index)
                    
                    
                }
                
                if selectedItems.isEmpty {
                    
                    selectedItems.append(wildcard)
                    
                }
                
            } else {
                
                if let index = selectedItems.firstIndex(of: wildcard) {
                    
                    selectedItems.remove(at: index)
                    
                }
                
                selectedItems.append(item)
                
            }
            
        case .single:
            
            selectedItems = [item]

        }
        
    }
    
}
