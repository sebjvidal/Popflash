//
//  MapsViewModel.swift
//  Popflash
//
//  Created by Seb Vidal on 10/02/2021.
//

import SwiftUI
import FirebaseFirestore

class MapsViewModel: ObservableObject {
    
    @Published var maps = [Map]()
    
    private var db = Firestore.firestore()
    
    func fetchData() {
        
        let db = Firestore.firestore()
        let ref = db.collection("maps")
        
        ref.getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else {
                
                return
                
            }
            
            if let error = error {
                
                print(error.localizedDescription)
                
            }
            
            for document in documents {
                
                guard let map = mapFrom(doc: document) else {
                    
                    return
                    
                }
                
                if !self.maps.contains(map) {
                    
                    self.maps.append(map)
                    
                }
                
            }
            
        }
        
    }
    
}
