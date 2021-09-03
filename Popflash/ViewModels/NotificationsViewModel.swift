//
//  NotificationsViewModel.swift
//  NotificationsViewModel
//
//  Created by Seb Vidal on 22/08/2021.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class NotificationsViewModel: ObservableObject {
    
    @Published var notifications = [String]()
    @Published var loading = Bool()
    
    func fetchData() {
        
        DispatchQueue.main.async {
            
            self.loading = true
            
            guard let user = Auth.auth().currentUser else {
                
                return
                
            }
            
            if user.isAnonymous {
                
                return
                
            }
            
            let db = Firestore.firestore()
            let ref = db.collection("users").document(user.uid)
            
            ref.getDocument { snapshot, error in
                
                guard let data = snapshot?.data() else {
                    
                    return
                    
                }
                
                if let error = error {
                    
                    print(error)
                    
                }
                
                if let notifications = data["notifications"] as? [String] {
                    
                    self.notifications = notifications
                    
                }
                
                self.loading = false
                
            }
            
        }
        
    }
    
}
