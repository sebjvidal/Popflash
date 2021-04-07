//
//  NadesViewModel.swift
//  Popflash
//
//  Created by Seb Vidal on 15/02/2021.
//

import SwiftUI
import Foundation
import FirebaseFirestore

class NadesViewModel: ObservableObject {
    
    @Published var nades = [Nade]()
    
    private var db = Firestore.firestore()
    
    func fetchData(ref: Query) {
            
            ref.getDocuments { (querySnapshot, error) in
                
                guard let documents = querySnapshot?.documents else {

                    return
                    
                }
                
                self.nades = documents.map { (queryDocumentSnapshot) -> Nade in
                    
                    let data = queryDocumentSnapshot.data()
                    
                    let id = data["id"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let map = data["map"] as? String ?? ""
                    let type = data["type"] as? String ?? ""
                    let side = data["side"] as? String ?? ""
                    let thumbnail = data["thumbnail"] as? String ?? ""
                    let video = data["video"] as? String ?? ""
                    let shortDescription = data["shortDescription"] as? String ?? ""
                    let longDescription = data["longDescription"] as? String ?? ""
                    let views = data["views"] as? Int ?? 0
                    let favourites = data["favourites"] as? Int ?? 0
                    let bind = data["bind"] as? String ?? ""
                    let tick = data["tick"] as? String ?? ""
                    let tags = data["tags"] as? Array ?? [String]()
                    let compliments = data["compliments"] as? Array ?? [String]()
                    
                    let nade = Nade(id: id,
                                    name: name,
                                    map: map,
                                    type: type,
                                    side: side,
                                    thumbnail: thumbnail,
                                    video: video,
                                    shortDescription: shortDescription,
                                    longDescription: longDescription,
                                    views: views,
                                    favourites: favourites,
                                    bind: bind,
                                    tick: tick,
                                    tags: tags,
                                    compliments: compliments)
                    
                    return nade
                    
                }
                
            }
        
    }
    
}
