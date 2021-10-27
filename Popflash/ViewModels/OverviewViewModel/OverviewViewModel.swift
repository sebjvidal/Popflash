//
//  OverviewViewModel.swift
//  OverviewViewModel
//
//  Created by Seb Vidal on 27/10/2021.
//

import SwiftUI
import FirebaseFirestore

class OverviewViewModel: ObservableObject {
    
    @Published var overviews: [Overview] = []
    @Published var callouts: [Callout] = []
    
    func fetchOverviews(for map: Map) {
            
        let db = Firestore.firestore()
        let ref = db.collection("overviews").document(map.id)
        
        ref.getDocument { snapshot, error in
            
            guard let document = snapshot else {
                
                return
                
            }
            
            guard let overview = overviewFrom(doc: document) else {
                
                return
                
            }
            
            self.overviews = [overview]
            
        }
        
    }
    
    func fetchCallouts(for map: Map) {
        
        let db = Firestore.firestore()
        let ref = db.collection("overviews").document(map.id).collection("callouts")
        
        ref.getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else {
                
                return
                
            }
            
            for document in documents {
                
                if let callout = calloutFrom(document: document) {
                    
                    self.callouts.append(callout)
                    
                }
                
            }
            
        }
        
    }
    
}
