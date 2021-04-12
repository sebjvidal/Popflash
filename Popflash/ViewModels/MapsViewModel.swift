//
//  MapsViewModel.swift
//  Popflash
//
//  Created by Seb Vidal on 10/02/2021.
//

import SwiftUI
import FirebaseFirestore
import Kingfisher

class MapsViewModel: ObservableObject {
    
    @Published var maps = [Map]()
    @Published var loading = false
    
    private var db = Firestore.firestore()
    private var lastDocument: QueryDocumentSnapshot!
    
    func fetchData(ref: Query) {
        
        self.loading = true
        
        var dbRef = ref.limit(to: 10)
        
        if !maps.isEmpty {
            
            dbRef = dbRef.start(afterDocument: lastDocument)
            
        }
        
        ref.getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                
                return
                
            }
            
            for document in documents {
                
                let data = document.data()
                
                let id = document.documentID
                let name = data["name"] as? String ?? ""
                let group = data["group"] as? String ?? ""
                let scenario = data["scenario"] as? String ?? ""
                let background = data["background"] as? String ?? ""
                let radar = data["radar"] as? String ?? ""
                let icon = data["icon"] as? String ?? ""
                let views = data["views"] as? Int ?? 0
                let lastAdded = data["lastAdded"] as? String ?? ""

                let map = Map(id: id,
                              name: name,
                              group: group,
                              scenario: scenario,
                              background: background,
                              radar: radar,
                              icon: icon,
                              views: views,
                              lastAdded: lastAdded)
                
                self.lastDocument = document
                
                if !self.maps.contains(map) { self.maps.append(map) }
                
            }
            
        }
        
        self.loading = false
        
    }
    
}
