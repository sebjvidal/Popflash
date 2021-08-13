//
//  RecentSection.swift
//  RecentSection
//
//  Created by Seb Vidal on 12/08/2021.
//

import SwiftUI

struct RecentSection: Hashable {
    
    var title: String
    var lowerBound: Date
    var upperBound: Date
    
}

enum Bound {
    
    case upper
    case lower
    
}
