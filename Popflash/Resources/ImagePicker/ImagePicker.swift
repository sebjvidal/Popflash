//
//  ImagePicker.swift
//  ImagePicker
//
//  Created by Seb Vidal on 31/07/2021.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let picker = UIImagePickerController()
        
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        
        return picker
        
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) { }
    
    func makeCoordinator() -> Coordinator {
        
        Coordinator(self)
        
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            
            self.parent = parent
            
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let uiImage = info[.editedImage] as? UIImage {
                
                parent.image = uiImage
                
            }
            
            parent.presentationMode.wrappedValue.dismiss()
            
        }
        
    }
    
}
