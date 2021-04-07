//
//  PageViewController.swift
//  Popflash
//
//  Created by Seb Vidal on 03/04/2021.
//

import SwiftUI
import UIKit

struct PageViewController<Page: View>: UIViewControllerRepresentable {
    
    var pages: [Page]
    
    func makeCoordinator() -> Coordinator {
        
        Coordinator(self)
        
    }
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal)
        
        pageViewController.dataSource = context.coordinator
        
        return pageViewController
        
    }
    
    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        
        pageViewController.setViewControllers(
            [context.coordinator.controllers[0]], direction: .forward, animated: true)
        
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        
        var parent: PageViewController
        var controllers = [UIViewController]()
        
        init(_ pageViewController: PageViewController) {
            
            parent = pageViewController
            controllers = parent.pages.map { UIHostingController(rootView: $0) }
            
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            
            guard let index = controllers.firstIndex(of: viewController) else {
                
                return nil
                
            }
            
            return (index - 1 == -1) ? nil : controllers[index - 1]
            
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            
            guard let index = controllers.firstIndex(of: viewController) else {
                
                return nil
                
            }
            
            return (index + 1 == controllers.count) ? nil : controllers[index + 1]

        }
        
    }
    
}
