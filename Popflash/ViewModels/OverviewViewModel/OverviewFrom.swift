//
//  OverviewFrom.swift
//  OverviewFrom
//
//  Created by Seb Vidal on 27/10/2021.
//

import SwiftUI
import FirebaseFirestore

func overviewFrom(doc document: DocumentSnapshot) -> Overview? {
    
    guard let data = document.data() else {
        
        return nil
        
    }
    
    let id = document.documentID
    let upperLevel = data["upperRadar"] as? String ?? ""
    let lowerLevel = data["lowerRadar"] as? String
    let scale = data["scale"] as? Double ?? 1
    
    let overview = Overview(id: id, upperRadar: upperLevel, lowerRadar: lowerLevel, scale: scale, callouts: [])
    
    return overview
    
}
