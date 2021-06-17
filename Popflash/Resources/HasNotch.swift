//
//  HasNotch.swift
//  Popflash
//
//  Created by Seb Vidal on 21/03/2021.
//

import SwiftUI

private let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

extension UIDevice {
    
    var hasNotch: Bool {
        
        let bottom = keyWindow?.safeAreaInsets.bottom ?? 0
        
//        return bottom > 0
        
        return true
        
    }
    
}
