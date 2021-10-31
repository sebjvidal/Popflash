//
//  OverviewTableViewCoordinator.swift
//  OverviewTableViewCoordinator
//
//  Created by Seb Vidal on 29/10/2021.
//

import SwiftUI

class OverviewTableViewCoordinator: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var parent: OverviewTableView
    var selection = "Upper Level"
    
    init(_ parent: OverviewTableView) {
        
        self.parent = parent
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return parent.callouts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let callout = parent.callouts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = callout.name
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let callout = parent.callouts[indexPath.row]
        
        if parent.calloutSelection == callout.name {
            
            parent.calloutSelection = ""
            
            tableView.deselectRow(at: indexPath, animated: false)
            
        } else {
            
            parent.calloutSelection = callout.name
            
        }
        
    }

}
