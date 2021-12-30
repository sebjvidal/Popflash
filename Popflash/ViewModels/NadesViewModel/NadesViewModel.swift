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
    private var lastDocument: QueryDocumentSnapshot!
    
    func fetchData(ref: Query, tagFilter: [String] = []) {
        var dbRef = ref
        
        if !nades.isEmpty {
            dbRef = dbRef.start(afterDocument: lastDocument)
        }
            
        dbRef.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                return
            }
            
            for document in documents {
                self.lastDocument = document
                
                guard let nade = nadeFrom(doc: document) else {
                    continue
                }
                
                if !self.nades.contains(nade) {
                    self.nades.append(nade)
                }
            }
        }
    }
}
