//
//  SkillGroupViewModel.swift
//  SkillGroupViewModel
//
//  Created by Seb Vidal on 29/07/2021.
//

import SwiftUI
import Foundation
import FirebaseFirestore

class SkillGroupViewModel: ObservableObject {
    
    @Published var skillGroups = [SkillGroup]()
    
    func fetchData() {
        
        let db = Firestore.firestore()
        let ref = db.collection("skillgroups")
        
        ref.getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                
                return
                
            }
            
            for document in documents {
                
                let data = document.data()
                
                let id = data["id"] as? Int ?? 0
                let skillGroup = data["skillGroup"] as? String ?? ""
                let icon = data["icon"] as? String ?? ""
                
                let skill = SkillGroup(id: id,
                                       skillGroup: skillGroup,
                                       icon: icon)
                
                self.skillGroups.append(skill)
                
            }
            
        }
        
    }
    
}
