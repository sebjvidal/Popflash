//
//  CalloutFrom.swift
//  CalloutFrom
//
//  Created by Seb Vidal on 27/10/2021.
//

import SwiftUI
import FirebaseFirestore

func calloutFrom(document doc: DocumentSnapshot) -> Callout? {
    
    guard let data = doc.data() else {
        
        return nil
        
    }
    
    let name = data["name"] as? String ?? ""
    let posX = data["posX"] as? Double ?? 0.0
    let posY = data["posY"] as? Double ?? 0.0
    let level = data["level"] as? String ?? "Upper"
    let thumbnail = data["thumbnail"] as? String ?? ""
    
    let callout = Callout(name: name, posX: posX, posY: posY, level: level, thumbnail: thumbnail)
    
    return callout
    
}
