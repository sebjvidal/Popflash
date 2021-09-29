//
//  ScrollOffsetPreferenceKey.swift
//  ScrollOffsetPreferenceKey
//
//  Created by Seb Vidal on 28/09/2021.
//

import SwiftUI

struct ScrollOffset: PreferenceKey {
    
    static var defaultValue: CGFloat = 0.0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
    
}
