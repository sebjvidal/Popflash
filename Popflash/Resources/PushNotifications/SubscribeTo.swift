//
//  SubscribeTo.swift
//  SubscribeTo
//
//  Created by Seb Vidal on 22/08/2021.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

func subscribe(to topic: String) {
    
    guard let user = Auth.auth().currentUser else {
        
        return
        
    }
    
    if user.isAnonymous {
        
        return
        
    }
    
    Messaging.messaging().subscribe(toTopic: topic) { error in
        
        if let error = error {
            
            print(error)
            
        }
        
    }
    
    let db = Firestore.firestore()
    let ref = db.collection("users").document(user.uid)
    
    ref.updateData(["topics" : FieldValue.arrayUnion([topic])])
    
}
