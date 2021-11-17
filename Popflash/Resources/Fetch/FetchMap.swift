//
//  FetchMap.swift
//  Popflash
//
//  Created by Seb Vidal on 17/11/2021.
//

import SwiftUI
import FirebaseFirestore

func fetchMap(withID id: String, completion: @escaping (Map) -> Void) {
    let db = Firestore.firestore()
    let ref = db.collection("map").document(id)
    
    ref.getDocument { snapshot, error in
        guard let document = snapshot else {
            return
        }
        
        if let map = mapFrom(doc: document) {
            completion(map)
        }
    }
}
