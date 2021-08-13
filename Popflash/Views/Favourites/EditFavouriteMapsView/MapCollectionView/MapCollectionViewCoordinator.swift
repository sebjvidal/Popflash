//
//  MapCollectionViewCoordinator.swift
//  MapCollectionViewCoordinator
//
//  Created by Seb Vidal on 07/08/2021.
//

import UIKit
import SwiftUI
import Kingfisher

class Coordinator: NSObject, UICollectionViewDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UICollectionViewDataSource {

    var parent: MapCollectionView
    var previousData = [Map]()
    
    init(_ parent: MapCollectionView) {
        
        self.parent = parent
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return self.parent.maps.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = self.parent.maps[indexPath.item]
        let cellWidth = (UIScreen.main.bounds.width - 64) / 3

        let backgroundImage = UIImageView()
        backgroundImage.kf.setImage(with: URL(string: self.parent.maps[indexPath.item].background))
        backgroundImage.frame = CGRect(x: 0, y: 0, width: cellWidth, height: cellWidth * 1.5)
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.layer.cornerCurve = .continuous
        backgroundImage.layer.cornerRadius = 15
        backgroundImage.clipsToBounds = true
        backgroundImage.layer.borderColor = UIColor.systemBlue.cgColor
        backgroundImage.layer.borderWidth = previousData.contains(item) ? 5 : 0

        let iconImage = UIImageView()
        iconImage.kf.setImage(with: URL(string: self.parent.maps[indexPath.item].icon))
        iconImage.frame = CGRect(x: (cellWidth / 2) - 40,
                                 y: ((cellWidth / 2) * 1.5) - 40,
                                 width: 80, height: 80)

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavouriteMapCell", for: indexPath)
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 5)
        cell.layer.shadowRadius = 6
        cell.layer.shadowOpacity = 0.15
        cell.backgroundColor = .clear

        cell.addSubview(backgroundImage)
        cell.addSubview(iconImage)
        cell.layer.cornerRadius = 15
        
        if self.parent.selectedMaps.contains(item) {

            if previousData.contains(item) {

                backgroundImage.layer.borderWidth = 5

            } else {

                UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {

                    backgroundImage.layer.borderWidth = 5

                }

            }

        } else {

            if previousData.contains(item) {

                UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
                    
                    backgroundImage.layer.borderWidth = 0
                    
                }

            } else {
                
                backgroundImage.layer.borderWidth = 0
                

            }

        }

        return cell

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let size = CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.width / 3)

        return size

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        previousData = self.parent.selectedMaps
        
        let item = self.parent.maps[indexPath.item]
        
        if self.parent.selectedMaps.contains(item) {
            
            if let index = self.parent.selectedMaps.firstIndex(of: item) {
                
                self.parent.selectedMaps.remove(at: index)
                
            }
            
        } else {
            
            self.parent.selectedMaps.append(item)
            
        }
        
        collectionView.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        let item = self.parent.maps[indexPath.item].id
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        
        return [dragItem]
        
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        if collectionView.hasActiveDrag {
            
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            
        } else {
            
            return UICollectionViewDropProposal(operation: .forbidden)
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        var destinationPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            
            destinationPath = indexPath
            
        } else {
            
            let item = collectionView.numberOfItems(inSection: 0)
            
            destinationPath = IndexPath(item: item - 1, section: 0)
            
        }
        
        if coordinator.proposal.operation == .move {
            
            self.reorderItems(coordinator: coordinator, destinationIndexPath: destinationPath, collectionView: collectionView)
            
        }
        
        DispatchQueue.main.async {
            
            collectionView.reloadData()
            
        }
        
    }
    
    func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        
        if let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath {
            
            let mapItem = self.parent.maps[sourceIndexPath.item]
            
            collectionView.performBatchUpdates {
                
                self.parent.maps.remove(at: sourceIndexPath.item)
                self.parent.maps.insert(mapItem, at: destinationIndexPath.item)
                
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
                
            }
            
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)

        }
        
    }
    
}
