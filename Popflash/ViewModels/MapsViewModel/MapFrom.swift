//
//  MapFrom.swift
//  MapFrom
//
//  Created by Seb Vidal on 08/08/2021.
//

import SwiftUI

import SwiftUI
import FirebaseFirestore

func mapFrom(doc: DocumentSnapshot) -> Map? {
    
    guard let data = doc.data() else {
        
        return nil
        
    }
    
    let id = doc.documentID
    let name = data["name"] as? String ?? ""
    let group = data["group"] as? String ?? ""
    let scenario = data["scenario"] as? String ?? ""
    let background = data["background"] as? String ?? ""
    let radar = data["radar"] as? String ?? ""
    let icon = data["icon"] as? String ?? ""
    let views = data["views"] as? Int ?? 0
    let lastAdded = data["lastAdded"] as? String ?? ""
    let favourite = data["favourite"] as? Bool ?? false
    let position = data["position"] as? Int ?? 0

    let map = Map(id: id,
                  name: name,
                  group: group,
                  scenario: scenario,
                  background: background,
                  radar: radar,
                  icon: icon,
                  views: views,
                  lastAdded: lastAdded,
                  favourite: favourite,
                  position: position)
    
    return map
    
}
