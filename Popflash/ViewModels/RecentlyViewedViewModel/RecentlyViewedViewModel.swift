//
//  RecentlyViewedViewModel.swift
//  RecentlyViewedViewModel
//
//  Created by Seb Vidal on 09/08/2021.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class RecentlyViewedViewModel: ObservableObject {
    @Published var nades: [Nade] = []
    
    private var lastDocument: QueryDocumentSnapshot!
    
    func fetchData(order: RecentlyViewedViewModelOrder = .newest) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        if user.isAnonymous {
            return
        }
        
        let db = Firestore.firestore()
        let descending = (order == .newest ? true : false)
        var ref = db.collection("users").document(user.uid).collection("recents").order(by: "dateAdded", descending: descending).limit(to: 50)
        
        if lastDocument != nil {
            ref = ref.start(afterDocument: lastDocument)
        }
        
        ref.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                return
            }
            
            for document in documents {
                let data = document.data()
                let dateAdded = data["dateAdded"] as? Double ?? 0
                
                guard let recentRef = data["ref"] as? DocumentReference else {
                    return
                }
                
                self.lastDocument = document
                
                recentRef.getDocument { nadeDocument, error in
                    guard let nadeDocument = nadeDocument else {
                        return
                    }
                    
                    guard var recentNade = nadeFrom(doc: nadeDocument) else {
                        return
                    }
                    
                    recentNade.dateAdded = dateAdded
                    recentNade.section = self.section(dateAdded: dateAdded)
                    
                    if !self.nades.contains(recentNade) {
                        self.nades.append(recentNade)
                    }
                }
            }
        }
    }
    
    private func section(dateAdded: Double) -> String {
        let dateBounds: [(title: String, bound: Date)] = [
            (title: "Today", bound: date()),
            (title: "Yesterday", bound: date(subtracting: 1)),
            (title: "Last 7 Days", bound: date(subtracting: 2)),
            (title: "Last Month", bound: date(subtracting: 8)),
            (title: "Last 3 Months", bound: date(subtracting: 31)),
            (title: "Last 6 Months", bound: date(subtracting: 91)),
            (title: "Last Year", bound: date(subtracting: 182)),
            (title: "All Time", bound: date(subtracting: 365))
        ]
        
        let dateStr = String(dateAdded)
        let dateObj = dateObject(from: dateStr)
        
        for (title, bound) in dateBounds.reversed() {
            if dateObj < bound {
                return title
            }
        }
        
        return "All Time"
    }
    
    func refresh() {
        self.nades.removeAll()
        self.lastDocument = nil
        
        fetchData()
    }
}
