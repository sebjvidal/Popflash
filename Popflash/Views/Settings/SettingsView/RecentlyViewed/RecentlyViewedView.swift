//
//  RecentlyViewedView.swift
//  RecentlyViewedView
//
//  Created by Seb Vidal on 16/07/2021.
//

import SwiftUI

struct RecentlyViewedView: View {
    
    var body: some View {
            
        List {
            
            Group {
                
                Header()
                
            }
            .listRowInsets(.some(EdgeInsets()))
            .listRowSeparator(.hidden)
            
        }
        .listStyle(.plain)
        .navigationBarTitle("", displayMode: .inline)
        
    }
    
}

private struct Header: View {
    
    var body: some View {
        
        VStack(spacing: 0) {

            Spacer()
                .frame(height: 8)

            HStack() {

                Text("Recently Viewed")
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                    .padding(.leading, 16)
                
                Spacer()

            }

            Divider()
                .padding(.top, 6)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

        }
        
    }
    
}
