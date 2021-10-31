//
//  OverviewTableView.swift
//  OverviewTableView
//
//  Created by Seb Vidal on 29/10/2021.
//

import SwiftUI

struct OverviewTableView: UIViewControllerRepresentable {
    
    @State var callouts: [Callout]
    @Binding var selection: String
    @Binding var calloutSelection: String
    
    let tableViewController = UITableViewController(style: .insetGrouped)
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<OverviewTableView>) -> UITableViewController {
        
        tableViewController.tableView.delegate = context.coordinator
        tableViewController.tableView.dataSource = context.coordinator
        tableViewController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableViewController.tableView.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
        
        return tableViewController
        
    }
    
    func updateUIViewController(_ uiViewController: UITableViewController, context: UIViewControllerRepresentableContext<OverviewTableView>) {
        
        updateSelection(context)
        
        if context.coordinator.selection != selection {

            clearSelection(context)
            
            context.coordinator.selection = selection

        }
        
        if calloutSelection == "" {
            
            clearSelection(context)
            
        }
        
        guard let row = callouts.firstIndex(where: { callout in
            
            callout.name == calloutSelection
            
        }) else {
            
            return
            
        }
        
        let indexPath = IndexPath(row: row, section: 0)
        
        tableViewController.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        
    }
    
    func makeCoordinator() -> OverviewTableViewCoordinator {
        
        OverviewTableViewCoordinator(self)
        
    }
    
    func updateSelection(_ context: UIViewControllerRepresentableContext<OverviewTableView>) {
        
        if context.coordinator.selection != selection {

            clearSelection(context)

            context.coordinator.selection = selection

        }
        
    }
    
    func clearSelection(_ context: UIViewControllerRepresentableContext<OverviewTableView>) {
        
        guard let indexPath = tableViewController.tableView.indexPathForSelectedRow else {
            
            return
            
        }
        
        tableViewController.tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
}
