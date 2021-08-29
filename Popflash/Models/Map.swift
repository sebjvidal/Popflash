//
//  Map.swift
//  Popflash
//
//  Created by Seb Vidal on 03/02/2021.
//

import SwiftUI

struct Map: Codable, Hashable, Identifiable {
    
    var id: String
    var name: String
    var group: String
    var scenario: String
    var background: String
    var radar: String
    var icon: String
    var views: Int
    var lastAdded: String
    var favourite: Bool
    var position: Int
    
}
