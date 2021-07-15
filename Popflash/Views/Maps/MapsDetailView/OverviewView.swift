//
//  OverviewView.swift
//  Popflash
//
//  Created by Seb Vidal on 04/07/2021.
//

import SwiftUI
import Kingfisher

struct OverviewView: View {
    
    var map: Map
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            KFImage(URL(string: map.radar))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.screenWidth,
                       height: UIScreen.screenWidth)
            
            List {

                ForEach(1...10, id: \.self) { index in

                    Text("Row \(index)")

                }

            }
            .edgesIgnoringSafeArea(.all )
            
        }
        
    }
    
}
