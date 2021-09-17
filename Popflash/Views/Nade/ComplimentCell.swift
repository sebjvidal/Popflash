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
        
        VStack(spacing: 0) {
            
            KFImage(URL(string: nade.thumbnail))
                .resizable()
                .aspectRatio(16/9, contentMode: .fit)
                .frame(width: 220)
        
            ZStack(alignment: .top) {
                
                KFImage(URL(string: nade.thumbnail))
                    .resizable()
                    .setProcessor(processor)
                    .frame(width: 220, height: 100)
                    .overlay(.regularMaterial)
                
                LazyVStack(alignment: .leading) {
                    
                    Text(nade.map)
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .padding(.leading, 11)
                        .foregroundStyle(.secondary)
                    
                    Text(nade.name)
                        .fontWeight(.semibold)
                        .padding(.top, 0)
                        .padding(.leading, 11)
                        .lineLimit(2)
                        .foregroundStyle(.primary)
                    
                    Text(nade.shortDescription)
                        .font(.callout)
                        .padding(.horizontal, 11)
                        .lineLimit(2)
                        .foregroundStyle(.secondary)
                    
                }
                .padding(.top, 8)
                
            }
            
        }
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .cellShadow()
        .padding(.trailing, 8)
        
    }
    
}
