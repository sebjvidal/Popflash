//
//  EditFavouriteMapsView.swift
//  Popflash
//
//  Created by Seb Vidal on 16/03/2021.
//

import SwiftUI
import FirebaseFirestore

struct EditFavouriteMapsView: View {
    
    @State var isEditMode: EditMode = .inactive
    
    @AppStorage("favourites.maps") var favouriteMaps = [String]()
    
    var maps = ["Dust II", "Mirage", "Nuke", "Inferno", "Overpass"]
    var notMaps = ["Cache", "Cobblestone", "Vertigo", "Anubis", "Train"]
    
    @ObservedObject var mapsViewModel = MapsViewModel()
    
    var body: some View {
        
        NavigationView {
            
            ZStack(alignment: .top) {
                
                List {
                    
                    Section() {
                        
                        ForEach(maps, id: \.self) { map in
                            
                            HStack {
                                
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 22))
                                
                                Text(map)
                                
                            }
                            
                        }
                        .onMove(perform: { indices, newOffset in
                            
                            print(newOffset)
                            
                        })
                        
                    }
                    
                    Section() {
                        
                        ForEach(notMaps, id: \.self) { map in
                            
                            HStack {
                                
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 22))
                                
                                Text(map)
                                
                            }
                            
                        }
                        .onMove(perform: { indices, newOffset in
                            
                            print(newOffset)
                            
                        })
                        
                    }
                    
                }
                .listStyle(GroupedListStyle())
                //            .deleteDisabled(true)
                .navigationBarTitle("Favourite Maps", displayMode: .inline)
                .environment(\.editMode, self.$isEditMode)
                .onAppear() {
                    
                    self.mapsViewModel.fetchData(ref: Firestore.firestore().collection("maps"))
                    
                }
                
                VisualEffectView(effect: UIBlurEffect(style: .extraLight))
                    .frame(height: 50)
                    .edgesIgnoringSafeArea(.all)
                
            }
            
        }
        
    }
    
}

struct EditFavouriteMapsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        EditFavouriteMapsView()
        
    }
    
}
