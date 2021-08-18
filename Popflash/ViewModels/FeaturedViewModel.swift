//
//  FeaturedViewModel.swift
//  FeaturedViewModel
//
//  Created by Seb Vidal on 18/08/2021.
//

import SwiftUI
import FirebaseFirestore

class FeaturedViewModel: ObservableObject {
    
    @Published var featuredNade = [Nade]()
    @Published var featuredMap = [Map]()
    
    func fetchData() {
        
        let db = Firestore.firestore()
        let nadeRef = db.collection("featured").whereField(FieldPath.documentID(), isEqualTo: "nade")
        let mapRef = db.collection("featured").whereField(FieldPath.documentID(), isEqualTo: "map")
        
        nadeRef.getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else {
                
                return
                
            }
            
            for document in documents {
                
                let nade = nadeFrom(doc: document)
                
                self.featuredNade = [nade]
                
            }

        }
        
        mapRef.getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else {
                
                return
                
            }
            
            for document in documents {
                
                let map = mapFrom(doc: document)
                
                self.featuredMap = [map]
                
            }
            
        }
        
    }
    
}
