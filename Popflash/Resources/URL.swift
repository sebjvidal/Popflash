//
//  URL.swift
//  URL
//
//  Created by Seb Vidal on 04/10/2021.
//

import SwiftUI

extension URL {
    
    var isDeepLink: Bool {
        
        return scheme == "popflash"
        
    }
    
    var isDynamicLink: Bool {
        
        return scheme == "https" && host == "popflash.app"
        
    }
    
    var tabIdentifier: Int? {
        
        guard isDeepLink else {
            
            return nil
            
        }
        
        switch host {
            
        case "featured":
            return 0
            
        case "maps":
            return 1
            
        case "favourites":
            return 2
            
        case "settings":
            return 3
            
        default:
            return nil
            
        }
        
    }
    
    var nadeID: String? {
        
        guard isDeepLink else {
            
            return nil
            
        }
        
        guard let id = absoluteString.components(separatedBy: "nade?=").last else {
            
            return nil
            
        }
        
        return id
        
    }
    
}
