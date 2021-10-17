//
//  ShareSheet.swift
//  ShareSheet
//
//  Created by Seb Vidal on 11/10/2021.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        controller.completionWithItemsHandler = { (activityType, completed: Bool, returnedItems: [Any]?, error: Error?) in
            
            if completed {
                
                controller.dismiss(animated: true)
                
            }
            
         }
        
        return controller
        
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
}
