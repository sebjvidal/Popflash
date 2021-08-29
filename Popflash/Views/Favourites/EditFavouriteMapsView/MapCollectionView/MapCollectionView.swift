//
//  MapCollectionView.swift
//  MapCollectionView
//
//  Created by Seb Vidal on 06/08/2021.
//

import UIKit
import SwiftUI
import Kingfisher
import FirebaseAuth
import FirebaseFirestore

struct MapCollectionView: UIViewControllerRepresentable {
    
    @StateObject var favouriteMaps = FavouriteMapsViewModel()
    
    @Binding var maps: [Map]
    @Binding var selectedMaps: [String]
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MapCollectionView>) -> UICollectionViewController {
        
        let cellWidth = (UIScreen.main.bounds.width - 64) / 3
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth * 1.5)
        
        let collectionViewController = UICollectionViewController(collectionViewLayout: layout)
        collectionViewController.collectionView.delegate = context.coordinator
        collectionViewController.collectionView.dragDelegate = context.coordinator
        collectionViewController.collectionView.dropDelegate = context.coordinator
        collectionViewController.collectionView.dataSource = context.coordinator
        collectionViewController.collectionView.register(FavouriteMapCollectionViewCell.self, forCellWithReuseIdentifier: "FavouriteMapCell")
        collectionViewController.collectionView.alwaysBounceVertical = true
        collectionViewController.collectionView.dragInteractionEnabled = true
        collectionViewController.collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionViewController.collectionView.backgroundColor = .clear
        
        loadMaps(collectionViewController.collectionView)
        loadFavourites(collectionViewController.collectionView)
        
        return collectionViewController
        
    }
    
    func updateUIViewController(_ uiViewController: UICollectionViewController, context: UIViewControllerRepresentableContext<MapCollectionView>) {}
    
    func makeCoordinator() -> Coordinator {
        
        Coordinator(self)
        
    }
    
    func loadMaps(_ collectionView: UICollectionView) {
        
        let db = Firestore.firestore()
        let ref = db.collection("maps").order(by: "name")
        
        ref.getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else {
                
                return
                
            }
            
            for document in documents {
                
                if let map = mapFrom(doc: document) {
                    
                    self.maps.append(map)
                    
                }
                
            }
            
            collectionView.reloadData()
            
        }
        
    }
    
    func loadFavourites(_ collectionView: UICollectionView) {

        guard let user = Auth.auth().currentUser else {
            
            return
            
        }
        
        if user.isAnonymous {
            
            return
            
        }
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user.uid).collection("maps")
        
        ref.getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else {
                
                return
                
            }

            for document in documents {
                
                let data = document.data()
                
                guard let mapRef = data["map"] as? DocumentReference else {
                    
                    return
                    
                }
                
                mapRef.getDocument { snapshot, error in
                    
                    guard let document = snapshot else {
                        
                        return
                        
                    }
                    
                    if let map = mapFrom(doc: document) {
                        
                        self.selectedMaps.append(map.id)
                        
                    }
                    
                    collectionView.reloadData()
                    
                }
                
            }
            
        }

    }
    
}
