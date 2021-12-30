//
//  RecentlyViewedView.swift
//  RecentlyViewedView
//
//  Created by Seb Vidal on 16/07/2021.
//

import SwiftUI

struct RecentlyViewedView: View {
    
    @StateObject var recentlyViewed = RecentlyViewedViewModel()
    
    @State private var selectedNade: Nade?
    
    var body: some View {
            
        List {
                
            Group {
                
                NadeList(recentNades: $recentlyViewed.nades,
                         selectedNade: $selectedNade)
                    .buttonStyle(FavouriteNadeCellButtonStyle())
                
                ActivityIndicator()
                    .onAppear(perform: loadMore)
                
            }
            .listRowSeparator(.hidden)
            .listRowInsets(.some(EdgeInsets()))
            
        }
        .refreshable {
            
            recentlyViewed.refresh()
            
        }
        .listStyle(.plain)
        .navigationBarTitle("Recently Viewed", displayMode: .large)
        .onAppear(perform: onAppear)
        .sheet(item: $selectedNade) { nade in
            
            NadeView(nade: nade)
            
        }
        
    }
    
    func onAppear() {
        if recentlyViewed.nades.isEmpty {
            recentlyViewed.fetchData()
        }
    }
    
    func loadMore() {
        if !recentlyViewed.nades.isEmpty {
            recentlyViewed.fetchData()
        }
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

        }
        
    }
    
}

private struct NadeList: View {
    @Binding var recentNades: [Nade]
    @Binding var selectedNade: Nade?
    
    let sections: [String] = [
        "Today",
        "Yesterday",
        "Last 7 Days",
        "Last Month",
        "Last 3 Months",
        "Last 6 Months",
        "Last Year",
        "All Time"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(sections, id: \.self) { section in
                if recentsContains(section) {
                    Divider()
                        .padding(.horizontal)
                        .padding(.bottom, 10)

                    Text(section).font(.title3)
                        .fontWeight(.semibold)
                        .padding(.leading, 18)
                        .padding(.bottom, 8)

                    ForEach(nades(section: section)) { nade in
                        Button(action: { viewNade(nade: nade) }) {
                            FavouriteNadeCell(nade: nade)
                                .equatable()
                        }
                        .padding([.horizontal, .bottom])
                        .buttonStyle(FavouriteNadeCellButtonStyle())
                    }
                }
            }
        }
    }
    
    func recentsContains(_ section: String) -> Bool {
        return recentNades.contains(where: { $0.section == section })
    }
    
    func nades(section: String) -> [Nade] {
        return recentNades.filter({ $0.section == section }).sorted(by: { $0.dateAdded > $1.dateAdded })
    }
    
    func viewNade(nade: Nade) {
        selectedNade = nade
    }
}
