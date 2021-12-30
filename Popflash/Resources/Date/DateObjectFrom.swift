//
//  DateObjectFrom.swift
//  DateObjectFrom
//
//  Created by Seb Vidal on 12/08/2021.
//

import SwiftUI

func dateObject(from dateString: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMddHHmmss"
    
    guard let date = formatter.date(from: dateString.replacingOccurrences(of: ".0", with: "")) else {
        return Date()
    }
    
    return date
}
