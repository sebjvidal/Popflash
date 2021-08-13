//
//  RecentlyViewedViewModel.swift
//  RecentlyViewedViewModel
//
//  Created by Seb Vidal on 09/08/2021.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class RecentlyViewedViewModel: ObservableObject {
    
    @Published var nades = [Nade]()
    
    private var lastDocument: QueryDocumentSnapshot!
    
    func fetchData(order: RecentlyViewedViewModelOrder = .newest) {
        
        guard let user = Auth.auth().currentUser else {
            
            return
            
        }
        
        if user.isAnonymous {
            
            return
            
        }
        
        // TODO: Implement order based off order enum
        
        let db = Firestore.firestore()
        var ref = db.collection("users").document(user.uid).collection("recentlyViewed").order(by: "dateAdded", descending: true)

        if !nades.isEmpty {
            
            ref = ref.start(afterDocument: lastDocument)
            
        }
        
        ref.addSnapshotListener { snapshot, error in
            
            guard let documents = snapshot?.documents else {
                
                return
                
            }
            
            if let error = error {
                
                print(error.localizedDescription)
                
            }
            
            self.nades.removeAll()
            
            for document in documents {
                
                let nade = nadeFrom(doc: document)
                
                self.nades.append(nade)
                self.lastDocument = document
                
            }
            
        }
        
    }
    
}

enum RecentlyViewedViewModelOrder {
    
    case newest
    case oldest
    case map
    
}
