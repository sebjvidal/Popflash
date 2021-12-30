//
//  NadeView.swift
//  Popflash
//
//  Created by Seb Vidal on 11/02/2021.
//

import SwiftUI

struct Detail: Hashable {
    var name: String
    var value: String
    var image: Image
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(value)
    }
}
