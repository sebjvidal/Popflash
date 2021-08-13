//
//  DateStringFrom.swift
//  DateStringFrom
//
//  Created by Seb Vidal on 13/08/2021.
//

import SwiftUI

func dateString(from date: Date) -> String {
    
    let formatter = DateFormatter()
    
    formatter.dateFormat = "yyyyMMddHHmmss"
    
    let dateString = formatter.string(from: date)
    
    return dateString
    
}
