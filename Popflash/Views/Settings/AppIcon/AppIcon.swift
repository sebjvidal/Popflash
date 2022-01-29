//
//  AppIcon.swift
//  Popflash
//
//  Created by Seb Vidal on 22/11/2021.
//

import SwiftUI

struct AppIcon: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var asset: String?
    var premium: Bool
    
    init(name: String, asset: String?, premium: Bool = false) {
        self.name = name
        self.asset = asset
        self.premium = premium
    }
}

enum ListPosition {
    case first
    case last
}
