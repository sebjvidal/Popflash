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
        
        if !self.nades.isEmpty {
            
            return
            
        }
        
        var recentIDs = [String: Double]()
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user.uid).collection("recents").order(by: "dateAdded", descending: true)
        
        ref.addSnapshotListener { snapshot, error in
            
            guard let documents = snapshot?.documents else { return }
            
            for document in documents {
                
                let data = document.data()
                
                let id = data["id"] as? String ?? ""
                let dateAdded = data["dateAdded"] as? Double ?? 0
                
                recentIDs[id] = dateAdded
                
            }
            
            self.fetchNades(for: recentIDs)
            
        }
        
    }
    
    func fetchNades(for nades: [String: Double]) {
        
        if nades.isEmpty {
            
            return
            
        }
        
        guard let user = Auth.auth().currentUser else {
            
            return
            
        }
        
        if user.isAnonymous {
            
            return
            
        }
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user.uid).collection("recents").whereField("id", in: Array(nades.keys)).order(by: "dateAdded", descending: true)
        
        ref.getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else {
                
                return
                
            }
            
            if let error = error {
                
                print(error.localizedDescription)
                
            }
            
            for document in documents {
                
                let nade = nadeFrom(doc: document)
                
                self.nades.append(nade)
                                
            }
            
        }
        
    }
    
}

enum RecentlyViewedViewModelOrder {
    
    case newest
    case oldest
    case map
    
}
