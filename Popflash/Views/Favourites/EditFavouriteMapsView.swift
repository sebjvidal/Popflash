//
//  EditFavouriteMapsView.swift
//  Popflash
//
//  Created by Seb Vidal on 16/03/2021.
//

import SwiftUI
import FirebaseFirestore

struct EditFavouriteMapsView: View {
    
    @StateObject var mapsViewModel = MapsViewModel()
    
    @AppStorage("favourites.maps") var favouriteMaps = [String]()
    
    var body: some View {
 
        NavigationView {
            
            ZStack(alignment: .top) {
                
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
                                
                            }
                            
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                    }
                    
                }
                .listStyle(GroupedListStyle())
                .navigationBarTitle("Favourite Maps", displayMode: .inline)
                .toolbar {
                    
                    DoneToolbarItem()
                    
                }
                .onAppear() {
                    
                    self.mapsViewModel.fetchData(ref: Firestore.firestore().collection("maps"))
                    
                }
                
                VStack(spacing: 0) {
                    
                    VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
                        .frame(height: 56)
                    
                    Divider()
                    
                }
                .edgesIgnoringSafeArea(.all)
                
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

struct EditFavouriteMapsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        EditFavouriteMapsView()
        
    }
    
}
