//
//  OverviewViewModel.swift
//  OverviewViewModel
//
//  Created by Seb Vidal on 27/10/2021.
//

import SwiftUI
import FirebaseFirestore

class OverviewViewModel: ObservableObject {
    
    @Published private(set) var overview: Overview?
    
    func fetchData(for map: Map) {
            
        let db = Firestore.firestore()
        let ref = db.collection("overviews").document(map.id)
        
        ref.getDocument { snapshot, error in
            
            guard let document = snapshot else {
                
                return
                
            }
            
            guard var overview = overviewFrom(doc: document) else {
                
                return
                
            }
            
            self.fetchCallouts(for: map) { [weak self] callouts in
                
                overview.callouts = callouts
                
                self?.overview = overview
                
            }
            
        }
        
    }
    
    private func fetchCallouts(for map: Map, completion: @escaping ([Callout]) -> Void) {
        
        var callouts: [Callout] = []
        
        let db = Firestore.firestore()
        let ref = db.collection("overviews").document(map.id).collection("callouts")
        
        ref.getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else {
                
                return
                
            }
            
            for document in documents {
                
                if let callout = calloutFrom(document: document) {
                    
                    callouts.append(callout)
                    
                }
                
            }
            
            completion(callouts)
            
        }
        
    }
    
}
