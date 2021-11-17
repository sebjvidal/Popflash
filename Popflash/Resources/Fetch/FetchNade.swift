//
//  FetchNade.swift
//  Popflash
//
//  Created by Seb Vidal on 17/11/2021.
//

import SwiftUI
import FirebaseFirestore

func fetchNade(withID id: String, completion: @escaping (Nade) -> Void) {
    let db = Firestore.firestore()
    let ref = db.collection("nades").whereField("id", isEqualTo: id).limit(to: 1)
    
    ref.getDocuments { snapshot, error in
        guard let documents = snapshot?.documents else {
            return
        }
        
        for document in documents {
            if let nade = nadeFrom(doc: document) {
                completion(nade)
            }
        }
    }
}
