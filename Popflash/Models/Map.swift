//
//  Map.swift
//  Popflash
//
//  Created by Seb Vidal on 03/02/2021.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Map: Codable, Hashable, Identifiable, Favouriteable {
    var id: String
    var name: String
    var group: String
    var scenario: String
    var background: String
    var radar: String
    var icon: String
    var views: Int
    var lastAdded: String
    var favourite: Bool
    var position: Int
    
    func getFavourite(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser, !user.isAnonymous else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let mapRef = db.collection("maps").document(id)
        let ref = db.collection("users").document(user.uid).collection("maps").whereField("map", isEqualTo: mapRef)
        
        ref.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                completion(false)
                return
            }
            
            completion(!documents.isEmpty)
        }
    }
}

extension Map {
    static let preview = Map(
        id: "dust2",
        name: "Dust II",
        group: "Active Duty",
        scenario: "Bomb Defusal",
        background: "https://firebasestorage.googleapis.com/v0/b/popflash-3e8b8.appspot.com/o/Backgrounds%2Fdust2_background.jpg?alt=media&token=fe15f376-15e6-4b3a-a6b5-35a5a7f184f7",
        radar: "",
        icon: "https://firebasestorage.googleapis.com/v0/b/popflash-3e8b8.appspot.com/o/Icons%2Fdust2_icon.png?alt=media&token=14a8732e-aa82-4d9a-9d8f-437f77f226b0",
        views: 0,
        lastAdded: "",
        favourite: false,
        position: 0
    )
}
