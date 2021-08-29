//
//  EditFavouriteMapsView.swift
//  Popflash
//
//  Created by Seb Vidal on 16/03/2021.
//

import SwiftUI
import Kingfisher
import FirebaseAuth
import FirebaseFirestore

struct EditFavouriteMapsView: View {
    
    @State var maps = [Map]()
    @State var selectedMaps = [String]()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View { 
        
        NavigationView {

            MapCollectionView(maps: $maps, selectedMaps: $selectedMaps)
                .edgesIgnoringSafeArea(.all)
                .navigationBarTitle("Edit Favourite Maps", displayMode: .inline)
                .navigationBarItems(
                    leading:
                        Button(action: cancel) {
                            Text("Cancel")
                                .fontWeight(.regular)
                        },
                    trailing:
                        Button(action: save) {
                            Text("Done")
                                .fontWeight(.bold)
                        }
                )
            
        }
        
    }
    
    func save() {
        
        removeExistingFavourites()
        
    }
    
    func cancel() {
        
        self.presentationMode.wrappedValue.dismiss()
        
    }
    
    func removeExistingFavourites() {
        
        guard let user = Auth.auth().currentUser else {
            
            return
            
        }
        
        if user.isAnonymous {
            
            return
            
        }
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user.uid).collection("maps")
        let batch = db.batch()
        
        ref.getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else {
                
                return
                
            }
            
            for document in documents {
                
                batch.deleteDocument(ref.document(document.documentID))
                
            }
            
            batch.commit { error in
                
                if let error = error {
                    
                    print(error.localizedDescription)
                    
                }
                
                addNewFavourites()
                
            }
            
        }
        
    }
    
    func addNewFavourites() {
        
        guard let user = Auth.auth().currentUser else {
            
            return
            
        }
        
        if user.isAnonymous {
            
            return
            
        }
        
        var favouriteMaps: [(id: String, position: Int)] = []
        
        for map in maps where selectedMaps.contains(map.id) {
            
            favouriteMaps.append((id: map.id, position: favouriteMaps.count))
            
        }
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user.uid).collection("maps")
        
        let batch = db.batch()

        for favourite in favouriteMaps {

            batch.setData([
                "map": db.collection("maps").document(favourite.id),
                "position": favourite.position
            ], forDocument: ref.document())

        }
        
        batch.commit { error in
            
            if let error = error {
                
                print(error.localizedDescription)
                
            }
            
        }
        
        self.presentationMode.wrappedValue.dismiss()
        
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
