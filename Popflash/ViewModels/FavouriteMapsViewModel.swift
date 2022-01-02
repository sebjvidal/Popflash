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
    private var listener: ListenerRegistration?
    
    func fetchData() {
        if let _ = listener {
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        if user.isAnonymous {
            return
        }
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user.uid).collection("maps")

        listener = ref.addSnapshotListener { [weak self] snapshot, error in
            guard let documents = snapshot?.documents else {
                return
            }

            self?.maps.removeAll()

            for document in documents {
                let data = document.data()

                guard let mapRef = data["map"] as? DocumentReference else {
                    return
                }

                let position = data["position"] as? Int ?? 0
                
                self?.fetchMap(from: mapRef, withPosition: position) { map in
                    if let existingMaps = self?.maps {
                        if !_maps.contains(map) {
                            self?.maps.append(map)
                        }
                    }
                }
            }
        }
    }
    
    private func fetchMap(from ref: DocumentReference, withPosition position: Int, completion: @escaping (Map) -> Void) {
        ref.getDocument { snapshot, error in
            guard let document = snapshot else {
                return
            }
            
            guard var map = mapFrom(doc: document) else {
                return
            }
            
            map.position = position
            
            completion(map)
        }
    }
    
    func clear() {
        if let listener = listener {
            listener.remove()
        }
        
        maps.removeAll()
    }
}
