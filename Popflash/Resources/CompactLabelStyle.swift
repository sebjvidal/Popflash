//
//  CompactLabelStyle.swift
//  CompactLabelStyle
//
//  Created by Seb Vidal on 07/11/2021.
//

import SwiftUI

struct CompactLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 10) {
            configuration.icon
            configuration.title
        }
    }
}

extension LabelStyle where Self == CompactLabelStyle {
    internal static var compact: CompactLabelStyle {
        return CompactLabelStyle()
    }
}
