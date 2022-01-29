//
//  Favouriteable.swift
//  Popflash
//
//  Created by Seb Vidal on 25/01/2022.
//

import SwiftUI

protocol Favouriteable {
    func getFavourite(completion: @escaping (Bool) -> Void)
//    func addToFavourites() -> Result<Any, Error>
//    func removeFromFavourites()  -> Result<Any, Error>
}
