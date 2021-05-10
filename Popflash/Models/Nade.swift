//
//  Nade.swift
//  Popflash
//
//  Created by Seb Vidal on 11/02/2021.
//

import SwiftUI

struct Nade: Hashable, Identifiable {
    
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
    var compliments: Array<String>
    var warning: String
    
}
