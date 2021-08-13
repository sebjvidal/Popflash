//
//  EditFavouriteMapsView.swift
//  Popflash
//
//  Created by Seb Vidal on 16/03/2021.
//

import SwiftUI
import Kingfisher
import FirebaseFirestore

struct EditFavouriteMapsView: View {
    
    @State var maps = [Map]()
    @State var selectedMaps = [Map]()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View { 
        
        NavigationView {

            MapCollectionView(maps: $maps, selectedMaps: $selectedMaps)
                .edgesIgnoringSafeArea(.all)
                .navigationBarTitle("Edit Favourite Maps", displayMode: .inline)
                .navigationBarItems(
                    leading:
                        Button(action: {
                            
                            self.presentationMode.wrappedValue.dismiss()
                            
                        }) {
                            Text("Cancel")
                                .fontWeight(.regular)
                        },
                    trailing:
                        Button(action: {
                            
                            self.presentationMode.wrappedValue.dismiss()
                            
                        }) {
                            Text("Done")
                                .fontWeight(.bold)
                        }
                )
            
        }
        
    }
    
}

private struct FavouriteMapCell: View {
    
    var map: Map
    
    @Binding var selectedMaps: [String]
    
    @State var selected = false
    
    let processor = CroppingImageProcessor(size: CGSize(width: 400, height: 600))
    
    var body: some View {
        
        Button(action: favouriteMap) {
            
            ZStack {
                
                KFImage(URL(string: map.background))
                    .setProcessor(processor)
                    .resizable()
                    .aspectRatio(CGSize(width: 1, height: 1.5), contentMode: .fill)
                
                KFImage(URL(string: map.icon))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 65)
                    .shadow(color: .black.opacity(0.5), radius: 10)
                
            }
            .drawingGroup()
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(selected ? .blue : .clear, lineWidth: 4)
            )
            .scaleEffect(selected ? 1.085 : 1)
            .animation(.easeInOut(duration: 0.15), value: selected)
            .cellShadow()
            
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        
    }
    
    func favouriteMap() {
        
        if let index = selectedMaps.firstIndex(of: map.id) {
            
            selectedMaps.remove(at: index)
            selected = false
            
        } else {
            
            selectedMaps.append(map.id)
            selected = true
            
        }
        
    }
    
}
