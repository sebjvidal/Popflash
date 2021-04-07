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
    
    private var db = Firestore.firestore()
    
    func fetchData(ref: Query) {
        
        ref.getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                
                return
                
            }
            
            self.maps = documents.map { (queryDocumentSnapshot) -> Map in
                
                let data = queryDocumentSnapshot.data()
                
                let id = queryDocumentSnapshot.documentID
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
                
                return map
                
            }
            
        }
        
    }
    
}
