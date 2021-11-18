//
//  DynamicLinkForMap.swift
//  DynamicLinkForMap
//
//  Created by Seb Vidal on 17/10/2021.
//

import SwiftUI
import FirebaseDynamicLinks

func dynamicLink(for map: Map, completion: @escaping (DynamicLink) -> Void) {
    
    guard let link = URL(string: "https://popflash.app/map?id=\(map.id)") else {
        
        completion(DynamicLink(link: URL(string: "")!))
        
        return
        
    }
    
    let dynamicLinkDomainURIPrefix = "https://popflash.app/map"
    let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinkDomainURIPrefix)
    
    linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.sebvidal.Popflash")
    linkBuilder?.iOSParameters?.appStoreID = "1578551834"
    linkBuilder?.iOSParameters?.customScheme = "popflash"
    
    linkBuilder?.options = DynamicLinkComponentsOptions()
    linkBuilder?.options?.pathLength = .short
    
    linkBuilder?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
    linkBuilder?.socialMetaTagParameters?.title = map.name
    linkBuilder?.socialMetaTagParameters?.descriptionText = "\(map.group) • \(map.scenario)"
    linkBuilder?.socialMetaTagParameters?.imageURL = URL(string: map.background)!
    
    linkBuilder?.navigationInfoParameters = DynamicLinkNavigationInfoParameters()
    linkBuilder?.navigationInfoParameters?.isForcedRedirectEnabled = true
    
    linkBuilder?.shorten { url, warnings, error in

        guard let dynamicLink = url else {

            completion(DynamicLink(link: URL(string: "")!))

            return

        }

        completion(DynamicLink(link: dynamicLink))

    }
    
}
