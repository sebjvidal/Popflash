//
//  SegmentedPicker.swift
//  Popflash
//
//  Created by Seb Vidal on 22/06/2021.
//

import SwiftUI

struct SegmentedPicker: View {
    
    var items: [String]
    var defaultsKey: String
    var wildcard: String = "All"
    var style: SegmentedPickerStyle = .default
    
    @Binding var selectedItems: String
    
    enum SegmentedPickerStyle {
        case `default`
        case single
    }
    
    var body: some View {
        
        HStack(spacing: 2) {
            
            Button {
                
                selectedItems = wildcard
                
            } label: {
                
                Rectangle()
                    .foregroundStyle(isSelected(item: wildcard) ? Color.blue : Color("Picker_Background"))
                    .overlay(Text(wildcard).font(.subheadline).foregroundStyle(isSelected(item: wildcard) ? Color("Selected") : Color("Unselected")))
                
            }
            
            ForEach(items, id: \.self) { item in
                
                Button {

                    segmentAction(item: item)

                } label: {
                    
                    Rectangle()
                        .foregroundStyle(isSelected(item: item) ? Color.blue : Color("Picker_Background"))
                        .overlay {
                            
                            if UIImage(named: "\(item)_Icon") != nil {
                                
                                Image("\(item)_Icon")
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 35)
                                    .font(.subheadline)
                                    .foregroundColor(isSelected(item: item) ? Color("Selected") : Color("Unselected"))
                                
                            } else {
                                
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
        
        if selectedItems == item {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
    func segmentAction(item: String) {
        
        if style == .single {
            
            selectedItems = item
            
        }
        
    }
    
}
