//
//  NadeBuilder.swift
//  NadeBuilder
//
//  Created by Seb Vidal on 03/08/2021.
//

import SwiftUI
import FirebaseFirestore

func nadeFrom(doc: DocumentSnapshot) -> Nade? {
    
    guard let data = doc.data() else {
        
        return nil
        
    }
    
    let documentID = doc.documentID
    let id = data["id"] as? String ?? ""
    let name = data["name"] as? String ?? ""
    let map = data["map"] as? String ?? ""
    let type = data["type"] as? String ?? ""
    let side = data["side"] as? String ?? ""
    let thumbnail = data["thumbnail"] as? String ?? ""
    let video = data["video"] as? String ?? ""
    let lineup = data["lineup"] as? String ?? ""
    let shortDescription = data["shortDescription"] as? String ?? ""
    let longDescription = data["longDescription"] as? String ?? ""
    let views = data["views"] as? Int ?? 0
    let favourites = data["favourites"] as? Int ?? 0
    let bind = data["bind"] as? String ?? ""
    let tick = data["tick"] as? String ?? ""
    let tags = data["tags"] as? Array ?? [String]()
    let dateAdded = data["dateAdded"] as? Double ?? 0
    let compliments = data["compliments"] as? Array ?? [String]()
    let warning = data["warning"] as? String ?? ""
    
    let nade = Nade(documentID: documentID,
                    id: id,
                    name: name,
                    map: map,
                    type: type,
                    side: side,
                    thumbnail: thumbnail,
                    video: video,
                    lineup: lineup,
                    shortDescription: shortDescription,
                    longDescription: longDescription,
                    views: views,
                    favourites: favourites,
                    bind: bind,
                    tick: tick,
                    tags: tags,
                    dateAdded: dateAdded,
                    compliments: compliments,
                    warning: warning)
    
    return nade
    
}
