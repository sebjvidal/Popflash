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
    var previousData: [String] = []
    
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
        
        let cell: FavouriteMapCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavouriteMapCell", for: indexPath) as! FavouriteMapCollectionViewCell
        cell.setupCell(map: item)
        cell.layer.cornerRadius = 15
        
        if self.parent.selectedMaps.contains(item.id) {

            cell.contentView.layer.opacity = 1
            cell.backgroundImage.transform = CGAffineTransform(scaleX: 1, y: 1)

        } else {
                
            cell.contentView.layer.opacity = 0.25
            cell.backgroundImage.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)


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
        let cell = collectionView.cellForItem(at: indexPath) as! FavouriteMapCollectionViewCell
        
        if self.parent.selectedMaps.contains(item.id) {

            if let index = self.parent.selectedMaps.firstIndex(of: item.id) {

                self.parent.selectedMaps.remove(at: index)
                
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {

                    cell.contentView.layer.opacity = 0.25
                    cell.backgroundImage.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

                }

            }

        } else {

            self.parent.selectedMaps.append(item.id)
            
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
                
                cell.contentView.layer.opacity = 1
                cell.backgroundImage.transform = CGAffineTransform(scaleX: 1, y: 1)

            }

        }
        
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

class FavouriteMapCollectionViewCell: UICollectionViewCell {
    
    var backgroundImage: UIImageView = UIImageView()
    var iconImage: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        let cellWidth = (UIScreen.main.bounds.width - 64) / 3

        backgroundImage.frame = CGRect(x: 0, y: 0, width: cellWidth, height: cellWidth * 1.5)
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.layer.cornerCurve = .continuous
        backgroundImage.layer.cornerRadius = 15
        backgroundImage.clipsToBounds = true
        
        iconImage.frame = CGRect(x: (cellWidth / 2) - 40,
                                 y: ((cellWidth / 2) * 1.5) - 40,
                                 width: 80, height: 80)
        
        backgroundImage.addSubview(iconImage)
        contentView.addSubview(backgroundImage)
        
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    func setupCell(map: Map) {
        
        backgroundImage.kf.setImage(with: URL(string: map.background))
        iconImage.kf.setImage(with: URL(string: map.icon))
        
    }
    
}
