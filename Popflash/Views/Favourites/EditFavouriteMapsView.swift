//
//  EditFavouriteMapsView.swift
//  Popflash
//
//  Created by Seb Vidal on 16/03/2021.
//

import SwiftUI
import FirebaseFirestore

struct EditFavouriteMapsView: View {
    
    @State var oldMapList = [String]()
    
    @StateObject var mapsViewModel = MapsViewModel()
    
    @AppStorage("favourites.maps") var favouriteMaps = [String]()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
 
        NavigationView {
                
            List {
                
                ForEach(mapsViewModel.maps, id: \.self) { map in
                    
                    Button {
                        
                        if !favouriteMaps.contains(map.name) {
                            
                            favouriteMaps.append(map.name)
                            
                        } else {
                            
                            if let mapIndex = favouriteMaps.firstIndex(of: map.name) {
                                
                                favouriteMaps.remove(at: mapIndex)
                                
                            }
                            
                        }
                        
                    } label: {
                        
                        HStack {
                            
                            Image(systemName: favouriteMaps.contains(map.name) ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 24))
                                .padding(.vertical, 4)
                                .foregroundColor(Color.blue)
                            
                            Text("\(map.name)")
                            
                            Spacer()
                            
                        }
                        
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                }
                
            }
            .navigationBarTitle("Favourite Maps", displayMode: .inline)
            .navigationBarItems(
                leading:
                    Button(action: {
                        
                        favouriteMaps = oldMapList
                        
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
            .onAppear() {
                
                self.mapsViewModel.fetchData(ref: Firestore.firestore().collection("maps"))
                
                oldMapList = favouriteMaps
                
            }
            
        }
        
    }
    
}

private struct DoneToolbarItem: ToolbarContent {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some ToolbarContent {
        
        ToolbarItem(placement: .navigationBarTrailing) {
            
            Button {
                
                self.presentationMode.wrappedValue.dismiss()
                
            } label: {
                
                Text("Done")
                    .fontWeight(.bold)
                
            }
            
        }
        
    }
    
}
