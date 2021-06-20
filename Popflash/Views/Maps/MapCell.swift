//
//  MapCell.swift
//  Popflash
//
//  Created by Seb Vidal on 15/04/2021.
//

import SwiftUI
import Kingfisher

struct MapCell: View {
    
    var map: Map
    
    @AppStorage("settings.compactMapsView") var compactMapsView = false
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            if !compactMapsView {
                
                KFImage(URL(string: map.background)!)
                    .resizable()
                    .loadImmediately()
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(Color("Loading"))
                    .background(Color("Loading"))
                    .frame(height: UIScreen.screenWidth / 1.777 - 32)
                
            }
            
            ZStack {
                
                let processor = CroppingImageProcessor(size: CGSize(width: 1284, height: 1), anchor: CGPoint(x: 0.5, y: 1))
                
                KFImage(URL(string: map.background)!)
                    .resizable()
                    .setProcessor(processor)
                    .loadImmediately()
                    .opacity(compactMapsView ? 0 : 1)
                    .frame(height: 80)
                    .overlay(.regularMaterial)
                
                HStack {
                    
                    KFImage(URL(string: map.icon))
                        .resizable()
                        .loadImmediately()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 55)
                        .padding(.leading, 12)
                    
                    VStack(alignment: .leading) {
                        
                        Text(map.name)
                            .font(.headline)
                        
                        Text(map.group)
                            .font(.subheadline)
                        
                    }
                    .padding(.leading, 4)
                    
                    Spacer()
                    
                    NewButton(lastAdded: map.lastAdded)
                    
                    Image(systemName: "chevron.right")
                        .padding(.trailing, 12)
                    
                }
                
            }
            
        }
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        
    }
    
}

private struct NewButton: View {
    
    var lastAdded: String
    
    var body: some View {
        
        if recentlyAdded(dateString: lastAdded) {
            
            ZStack {
                
                Rectangle()
                    .frame(width: 75, height: 26)
                    .foregroundColor(.blue)
                    .cornerRadius(13)
                
                Text("NEW")
                    .font(.headline)
                    .foregroundColor(.white)
                
            }
            
        }
        
    }
    
    func recentlyAdded(dateString: String) -> Bool {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd-MM-y"
        
        let calendar = Calendar.current
        let currentDate = Date()
        guard let lastAddedDate = dateFormatter.date(from: dateString) else { return false }
        
        var dateComponent = DateComponents()
        
        dateComponent.day = -7
        
        guard let dateThreshold = calendar.date(byAdding: dateComponent, to: currentDate) else { return false }
        
        if lastAddedDate > dateThreshold {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
}
