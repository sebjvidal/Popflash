//
//  Date.swift
//  Date
//
//  Created by Seb Vidal on 12/08/2021.
//

import SwiftUI

func date(bound: Bound, subtracting subrtraction: Int = 0) -> Date {
    
    let currentDate = Date()
    
    var dateComponents = Calendar.current.dateComponents(
        [.year, .month, .day, .hour, .minute, .second],
        from: currentDate
    )
    
    dateComponents.hour = (bound == .upper ? 24 : 1)
    dateComponents.minute = (bound == .upper ? 59 : 0)
    dateComponents.second = (bound == .upper ? 59 : 0)
    
    var subtractionComponent = DateComponents()
    subtractionComponent.day = -subrtraction
    
    guard let date = Calendar.current.date(from: dateComponents) else {
        
        return Date()
        
    }
        
    guard let dateBound = Calendar.current.date(byAdding: subtractionComponent, to: date) else {
        
        return Date()
        
    }
    
    return dateBound
    
}
