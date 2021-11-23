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
}

enum ListPosition {
    case first
    case last
}
