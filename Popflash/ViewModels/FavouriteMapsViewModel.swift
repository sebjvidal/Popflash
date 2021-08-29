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
    
    init() {
        
        fetchData()
        
    }
    
    func fetchData() {
        
        guard let user = Auth.auth().currentUser else {
            
            return
            
        }
        
        if user.isAnonymous {
            
            return
            
        }
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user.uid).collection("maps")

        ref.addSnapshotListener { snapshot, error in

            guard let documents = snapshot?.documents else {

                return

            }

            self.maps.removeAll()

            for document in documents {

                let data = document.data()

                guard let mapRef = data["map"] as? DocumentReference else {

                    return

                }

                let position = data["position"] as? Int ?? 0

                mapRef.getDocument { snapshot, error in

                    guard let document = snapshot else {

                        return

                    }

                    if var map = mapFrom(doc: document) {

                        map.position = position

                        self.maps.append(map)

                    }

                }

            }

        }
        
    }
    
}
