//
//  Overview.swift
//  Overview
//
//  Created by Seb Vidal on 27/10/2021.
//

import SwiftUI

struct Overview: Hashable {
    
    var id: String
    var upperRadar: String
    var lowerRadar: String?
    var scale: Double
    var callouts: [Callout]
    
    func upperCallouts() -> [Callout] {
        
        let calls = callouts.filter { call in
            
            return call.level == "Upper"
            
        }.sorted(by: {
            
            $0.name < $1.name
            
        })
        
        return calls
        
    }
    
    func lowerCallouts() -> [Callout] {
        
        let calls = callouts.filter { call in
            
            return call.level == "Lower"
            
        }.sorted(by: {
            
            $0.name < $1.name
            
        })
        
        return calls
        
    }
    
}
