//
//  Callout.swift
//  Callout
//
//  Created by Seb Vidal on 27/10/2021.
//

import SwiftUI

struct Callout: Identifiable, Hashable {
    
    var id = UUID()
    var name: String
    var posX: Double
    var posY: Double
    var level: String
    var thumbnail: String
    
}
