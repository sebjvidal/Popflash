//
//  FavouritesViewModel.swift
//  FavouritesViewModel
//
//  Created by Seb Vidal on 03/08/2021.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Foundation

class FavouritesViewModel: ObservableObject {
    
    @Published var nades = [Nade]()
    
    func fetchData() {
        
        guard let user = Auth.auth().currentUser else {
            
            return
        
        }
        
        if user.isAnonymous {
            
            return
            
        }
        
        if nades.isEmpty {
            
            let db = Firestore.firestore()
            let ref = db.collection("users").document(user.uid).collection("nades").order(by: "dateAdded", descending: true)
            
            ref.addSnapshotListener { querySnapshot, error in
                
                guard let documents = querySnapshot?.documents else {
                    
                    return
                    
                }
                
                self.nades.removeAll()
                
                for document in documents {
                    
                    guard let nade = nadeFrom(doc: document) else {
                        
                        continue
                        
                    }
                    
                    self.nades.append(nade)
                                    
                }
                
            }
            
        }

    }
    
    func clear() {
        
        nades.removeAll()
        
    }
    
}
