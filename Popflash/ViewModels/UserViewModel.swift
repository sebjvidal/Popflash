//
//  UserViewModel.swift
//  UserViewModel
//
//  Created by Seb Vidal on 30/07/2021.
//

import SwiftUI
import Firebase
import Foundation

class UserViewModel: ObservableObject {
    
    @Published var id = String()
    @Published var displayName = String()
    @Published var skillGroup = String()
    
    func fetchData(forUser: String) {
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(forUser)
        
        ref.addSnapshotListener { documentSnapshot, error in
            
            guard let document = documentSnapshot else {
                
                return
                
            }
            
            guard let data = document.data() else {
                
                return
                
            }
            
            self.id = document.documentID
            self.displayName = data["displayName"] as? String ?? "Display Name"
            self.skillGroup = data["skillGroup"] as? String ?? "Unknown"
            
        }
        
    }
    
    func clearData() {
        
        self.id = String()
        self.displayName = String()
        self.skillGroup = String()
        
    }
    
}
