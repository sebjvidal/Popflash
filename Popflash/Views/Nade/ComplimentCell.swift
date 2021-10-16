//
//  ComplimentCell.swift
//  Popflash
//
//  Created by Seb Vidal on 07/05/2021.
//

import SwiftUI
import Kingfisher

struct ComplimentCell: View {
    
    var nade: Nade
    
    let processor = CroppingImageProcessor(size: CGSize(width: 1284, height: 1), anchor: CGPoint(x: 0.5, y: 1.0))
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            KFImage(URL(string: nade.thumbnail))
                .resizable()
                .aspectRatio(16/9, contentMode: .fill)
                .frame(width: 220, height: 124)
            
            ZStack(alignment: .topLeading) {

                KFImage(URL(string: nade.thumbnail))
                    .resizable()
                    .setProcessor(processor)
                    .frame(width: 220)
                    .overlay(.regularMaterial)

                VStack(alignment: .leading, spacing: 0) {

                    Text(nade.map)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)

                    Text(nade.name)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(nade.shortDescription)
                        .font(.callout)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                }
                .padding(.horizontal, 11)
                .padding(.bottom, 10)

            }
            
        }
        .frame(width: 220)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .cellShadow()
        
    }
    
}
