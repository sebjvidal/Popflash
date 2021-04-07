//
//  DownloadImage.swift
//  Popflash
//
//  Created by Seb Vidal on 21/02/2021.
//

import SwiftUI
import Kingfisher

func downloadImage(`with` urlString : String){
    guard let url = URL.init(string: urlString) else {
        return
    }
    let resource = ImageResource(downloadURL: url)

    KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
        switch result {
        case .success(let value):
            print("Image: \(value.image). Got from: \(value.cacheType)")
        case .failure(let error):
            print("Error: \(error)")
        }
    }
}
