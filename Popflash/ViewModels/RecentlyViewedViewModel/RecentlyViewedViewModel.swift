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
        
        let db = Firestore.firestore()
        let descending = (order == .newest ? true : false)
        var ref = db.collection("users").document(user.uid).collection("recents").order(by: "dateAdded", descending: descending).limit(to: 10)
        
        if lastDocument != nil {
            
            ref = ref.start(afterDocument: lastDocument)
            
        }
        
        ref.addSnapshotListener { snapshot, error in
            
            guard let documents = snapshot?.documents else {
                
                return
                
            }
            
            var recentIDs = [NadePointer]()
            
            for document in documents {
                
                let data = document.data()
                
                let id = data["id"] as? String ?? ""
                let dateAdded = data["dateAdded"] as? Double ?? 0
                
                recentIDs.append(NadePointer(id: id, dateAdded: dateAdded))
                
                self.lastDocument = document

            }
            
            self.fetchNades(for: recentIDs)
            
        }
        
    }
    
    private func fetchNades(for pointers: [NadePointer]) {
        
        if pointers.isEmpty {
            
            return
            
        }
        
        guard let user = Auth.auth().currentUser else {
            
            return
            
        }
        
        if user.isAnonymous {
            
            return
            
        }
        
        let db = Firestore.firestore()
        let ref = db.collection("nades").whereField("id", in: pointerIDs(for: pointers)).limit(to: 10)
        
        ref.getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else {
                
                return
                
            }
            
            if let error = error {
                
                print(error.localizedDescription)
                
            }
            
            for pointer in pointers {
                
                guard let document = documents.first(where: { snapshot in
                    
                    snapshot.data()["id"] as! String == pointer.id
                    
                }) else {
                    
                    return
                    
                }
                
                guard var nade = nadeFrom(doc: document) else {
                    
                    continue
                    
                }
                
                nade.dateAdded = pointer.dateAdded
                
                if !self.nades.isEmpty {
                    
                    guard let first = self.nades.first else {
 
                        continue
                        
                    }
                    
                    if first.id == nade.id || self.nades.contains(nade) {
                        
                        continue
                        
                    }
                    
                }
                
                self.nades.append(nade)
                
            }
            
        }
        
    }
    
    private func pointerIDs(for pointers: [NadePointer]) -> [String] {
        
        var IDs = [String]()
        
        for pointer in pointers {
            
            IDs.append(pointer.id)
            
        }
        
        return IDs
        
    }
    
}

struct NadePointer: Identifiable {
    
    var id: String
    var dateAdded: Double
    
}
