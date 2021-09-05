//
//  UnsubscribeFrom.swift
//  UnsubscribeFrom
//
//  Created by Seb Vidal on 22/08/2021.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

func unsubscribe(from topic: String) {
    
    guard let user = Auth.auth().currentUser else {
        
        return
        
    }
    
    if user.isAnonymous {
        
        return
        
    }
    
    Messaging.messaging().unsubscribe(fromTopic: topic) { error in
        
        if let error = error {
            
            print(error)
            
        }
        
    }
    
    let db = Firestore.firestore()
    let ref = db.collection("users").document(user.uid)
    
    ref.updateData(["topics" : FieldValue.arrayRemove([topic])])
    
}
