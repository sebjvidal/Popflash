//
//  Nade.swift
//  Popflash
//
//  Created by Seb Vidal on 11/02/2021.
//

import SwiftUI

struct Nade: Codable, Hashable, Identifiable {
    var id = UUID()
    var documentID: String
    var nadeID: String
    var name: String
    var map: String
    var type: String
    var side: String
    var thumbnail: String
    var video: String
    var lineup: String
    var shortDescription: String
    var longDescription: String
    var views: Int
    var favourites: Int
    var bind: String
    var tick: String
    var tags: Array<String>
    var dateAdded: Double
    var compliments: Array<String>
    var warning: String
    var section: String
}

extension Nade {
    static let empty = Nade(documentID: "", nadeID: "", name: "", map: "", type: "", side: "", thumbnail: "", video: "", lineup: "", shortDescription: "", longDescription: "", views: 0, favourites: 0, bind: "", tick: "", tags: [], dateAdded: 0, compliments: [], warning: "", section: "Today")
    static let widgetPreview = Nade(documentID: "", nadeID: "", name: "XBox Smoke", map: "Dust II", type: "", side: "", thumbnail: "https://firebasestorage.googleapis.com/v0/b/popflash-3e8b8.appspot.com/o/Thumbnails%2FDust%20II%2Fdust2_xbox_smoke.png?alt=media&token=d2a739fd-c093-43f3-9799-1b19c575e96e", video: "", lineup: "", shortDescription: "Smoke XBox from T Spawn.", longDescription: "", views: 0, favourites: 0, bind: "", tick: "", tags: [], dateAdded: 0, compliments: [], warning: "", section: "Today")
}
