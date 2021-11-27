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
    @Published var nades: [Nade] = []
    private var lastDocument: QueryDocumentSnapshot!
    
    func fetchData(order: RecentlyViewedViewModelOrder = .newest) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        if user.isAnonymous {
            return
        }
        
        let db = Firestore.firestore()
        let descending = (order == .newest ? true : false)
        var ref = db.collection("users").document(user.uid).collection("recents").order(by: "dateAdded", descending: descending).limit(to: 10)
        
        if lastDocument != nil {
            ref = ref.start(afterDocument: lastDocument)
        }
        
        ref.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                return
            }
            
            for document in documents {
                let data = document.data()
                let dateAdded = data["dateAdded"] as? Double ?? 0
                
                guard let recentRef = data["ref"] as? DocumentReference else {
                    return
                }
                
                self.lastDocument = document
                
                recentRef.getDocument { nadeDocument, error in
                    guard let nadeDocument = nadeDocument else {
                        return
                    }
                    
                    guard var recentNade = nadeFrom(doc: nadeDocument) else {
                        return
                    }
                    
                    recentNade.dateAdded = dateAdded
                    
                    self.nades.append(recentNade)
                }
            }
        }
    }
    
    func refresh() {
        self.nades.removeAll()
        self.lastDocument = nil
        
        fetchData()
    }
}
