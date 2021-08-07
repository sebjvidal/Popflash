//
//  Nade.swift
//  Popflash
//
//  Created by Seb Vidal on 11/02/2021.
//

import SwiftUI

struct Nade: Encodable, Hashable, Identifiable {
    
    var documentID: String
    var id: String
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
    
    enum CodingKeys: String, CodingKey {
        case documentID
        case id
        case name
        case map
        case type
        case side
        case thumbnail
        case video
        case lineup
        case shortDescription
        case longDescription
        case views
        case favourites
        case bind
        case tick
        case tags
        case dateAdded
        case compliments
        case warning
    }
    
}
