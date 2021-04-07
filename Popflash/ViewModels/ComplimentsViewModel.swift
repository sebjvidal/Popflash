//
//  ComplimentsViewModel.swift
//  Popflash
//
//  Created by Seb Vidal on 14/03/2021.
//

import SwiftUI
import FirebaseFirestore

class ComplimentsViewModel: ObservableObject {
    
    @Published var complimentsNades = [Nade]()
    
    private var db = Firestore.firestore()
    
    func fetchData(nades: [String]) {
        
        if !nades.isEmpty {
            
            db.collection("nades").whereField("id", in: nades).getDocuments { (querySnapshot, error) in
                
                guard let documents = querySnapshot?.documents else {
                    
                    return
                    
                }
                
                self.complimentsNades = documents.map { (queryDocumentSnapshot) -> Nade in
                    
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
    
}
