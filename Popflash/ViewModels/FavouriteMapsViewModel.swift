//
//  FavouriteMapsViewModel.swift
//  FavouriteMapsViewModel
//
//  Created by Seb Vidal on 08/08/2021.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class FavouriteMapsViewModel: ObservableObject {
    
    @Published var maps = [Map]()
    
    func fetchData() {
        
        guard let user = Auth.auth().currentUser else { return }
        
        if user.isAnonymous { return }
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user.uid).collection("maps").order(by: "position")
        
        ref.addSnapshotListener { snapshot, error in
            
            guard let documents = snapshot?.documents else { return }
            
            self.maps = documents.map { querySnapshot -> Map in
                
                return mapFrom(doc: querySnapshot)
                
            }
            
        }
        
    }
    
}
