//
//  ImageResizer.swift
//  ImageResizer
//
//  Created by Seb Vidal on 01/08/2021.
//

import SwiftUI

extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
