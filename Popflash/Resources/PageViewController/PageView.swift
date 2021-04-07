//
//  PageView.swift
//  Popflash
//
//  Created by Seb Vidal on 03/04/2021.
//

import SwiftUI

struct PageView<Page: View>: View {
    
    var pages: [Page]

    var body: some View {
        
        PageViewController(pages: pages)
        
    }
    
}
