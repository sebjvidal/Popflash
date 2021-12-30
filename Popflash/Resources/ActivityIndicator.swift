//
//  ActivityIndicator.swift
//  ActivityIndicator
//
//  Created by Seb Vidal on 24/08/2021.
//

import SwiftUI

struct ActivityIndicator: View {
    var style: UIActivityIndicatorView.Style = .medium
    
    var body: some View {
        switch style {
        case .large:
            UIActivityIndicatorViewUIViewRepresentable()
        default:
            LazyVStack {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
}

struct UIActivityIndicatorViewUIViewRepresentable: UIViewRepresentable {
    let activityIndicator = UIActivityIndicatorView()
    
    func makeUIView(context: UIViewRepresentableContext<UIActivityIndicatorViewUIViewRepresentable>) -> UIActivityIndicatorView {
        activityIndicator.style = .large
        activityIndicator.startAnimating()
        
        return activityIndicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<UIActivityIndicatorViewUIViewRepresentable>) {}
}
