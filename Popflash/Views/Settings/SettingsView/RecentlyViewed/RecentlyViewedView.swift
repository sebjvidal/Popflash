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
                
                Header()
                
                NadeList(recentNades: $recentlyViewed.nades,
                         selectedNade: $selectedNade)
                
                ActivityIndicator()
                    .onAppear(perform: loadMore)
                
            }
            .listRowInsets(.some(EdgeInsets()))
            .listRowSeparator(.hidden)
            
        }
        .listStyle(.plain)
        .navigationBarTitle("", displayMode: .inline)
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
    
    let sections = [RecentSection(title: "Today", lowerBound: date(bound: .lower), upperBound: date(bound: .upper)),
                    RecentSection(title: "Yesterday", lowerBound: date(bound: .lower, subtracting: 1), upperBound: date(bound: .upper, subtracting: 1)),
                    RecentSection(title: "Last 7 Days", lowerBound: date(bound: .lower, subtracting: 7), upperBound: date(bound: .upper, subtracting: 2)),
                    RecentSection(title: "Last Month", lowerBound: date(bound: .lower, subtracting: 30), upperBound: date(bound: .upper, subtracting: 8)),
                    RecentSection(title: "Last 3 Months", lowerBound: date(bound: .lower, subtracting: 91), upperBound: date(bound: .upper, subtracting: 31)),
                    RecentSection(title: "Last 6 Months", lowerBound: date(bound: .lower, subtracting: 182), upperBound: date(bound: .upper, subtracting: 91)),
                    RecentSection(title: "Last Year", lowerBound: date(bound: .lower, subtracting: 365), upperBound: date(bound: .upper, subtracting: 182))]
    
    var body: some View {
        
        Group {
            
            ForEach(sections, id: \.self) { section in
            
                if recentNades.contains(where: { nade in
                    
                    section.lowerBound...section.upperBound ~= dateObject(from: String(nade.dateAdded))
                    
                }) {
                    
                    Text(section.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.leading, 18)
                    
                    ForEach(nadesIn(section: section), id: \.self) { nade in
                        
                        Button {

                            viewNade(nade: nade)

                        } label: {

                            FavouriteNadeCell(nade: nade)

                        }
                        .padding(.horizontal)
                        .padding(.bottom, lastNade(nade: nade, inSection: section) ? nade == recentNades.last ? 16 : 0 : 16)
                        
                    }
                    
                }
            
            }
            
            if recentNades.contains(where: { nade in
                
                dateObject(from: String(nade.dateAdded)) < date(bound: .lower, subtracting: 365)
                
            }) {
                
                Text("All Time")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.leading, 18)
                
                ForEach(otherNades(), id: \.self) { nade in
                    
                    Button {

                        viewNade(nade: nade)

                    } label: {

                        FavouriteNadeCell(nade: nade)

                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                }
                
            }
            
        }
        .buttonStyle(FavouriteNadeCellButtonStyle())
        
    }
    
    func viewNade(nade: Nade) {
        
        selectedNade = nade
        
    }
    
    func nadesIn(section: RecentSection) -> [Nade] {
        
        var nades = [Nade]()
        
        for nade in recentNades where section.lowerBound...section.upperBound ~= dateObject(from: String(nade.dateAdded)) {
            
            nades.append(nade)
            
        }
        
        return nades
        
    }
    
    func otherNades() -> [Nade] {
        
        var nades = [Nade]()
        
        for nade in recentNades {
            
            if dateObject(from: String(nade.dateAdded)) < date(bound: .lower, subtracting: 365) {
                
                nades.append(nade)
                
            }
            
        }
        
        return nades
        
    }
    
    func lastNade(nade: Nade, inSection section: RecentSection) -> Bool {
        
        if let last = nadesIn(section: section).last(where: { nade in
            
            section.lowerBound...section.upperBound ~= dateObject(from: String(nade.dateAdded))
            
        }) {
            
            if nade == last {
                
                return true
                
            }
            
        }
        
        return false
        
    }
    
}
