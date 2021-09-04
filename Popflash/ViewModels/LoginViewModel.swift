//
//  LoginViewModel.swift
//  LoginViewModel
//
//  Created by Seb Vidal on 25/07/2021.
//

import SwiftUI
import Firebase
import CryptoKit
import AuthenticationServices

class LoginViewModel: ObservableObject {
    
    @Published var nonce = ""
    @AppStorage("loggedInStatus") var loggedInStatus = false
    
    func authenticate(credential: ASAuthorizationAppleIDCredential) {
        
        guard let token = credential.identityToken else {
            
            print("Error fetching ASAuthorisationAppleIDRequest credential identity token.")
            
            return
            
        }
        
        guard let tokenString = String(data: token, encoding: .utf8) else {
            
            return
            
        }
        
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
        
        Auth.auth().signIn(with: firebaseCredential) { (result, error) in

            if let error = error {

                print(error.localizedDescription)

                return

            }

            self.loggedInStatus = true

            print("Logged into Firebase successfully.")
            
            if let uid = result?.user.uid {
                
                createFirestoreAccount(user: uid, credential: credential)
                
            } else {
                
                print("result.user.uid returned nil.")
                
            }

        }
        
    }
    
}

func createFirestoreAccount(user: String, credential: ASAuthorizationAppleIDCredential) {

    if let uid = Auth.auth().currentUser?.uid {
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(uid)
        
        let names = [credential.fullName?.givenName,
                     credential.fullName?.familyName]
        
        let displayName = names.compactMap({ $0 }).joined(separator: " ")
        
        var data: [String: Any] = [:]
        
        if !displayName.isEmpty {
            
            data["displayName"] = displayName
            
        }

        ref.setData(data, merge: true) { error in
            
            if let error = error {
                
                print(error.localizedDescription)
                
            }
            
        }
        
    }
    
}

func authenticateAnonymously() {
    
    Auth.auth().signInAnonymously() { (authResult, error) in
        
        guard let user = authResult?.user else {
            
            print("Anonymous authentication failed.")
            
            return
            
        }
        
        let _ = user.isAnonymous
        let _ = user.uid
        
    }
    
}

func randomNonceString(length: Int = 32) -> String {
    
    precondition(length > 0)
    
    let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            
            if errorCode != errSecSuccess {
                
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode).")
                
            }
            
            return random
            
        }
        
        randoms.forEach { random in
            
            if remainingLength == 0 {
                
                return
                
            }
            
            if random < charset.count {
                
                result.append(charset[Int(random)])
                remainingLength -= 1
                
            }
            
        }
        
    }
    
    return result
    
}

func sha256(_ input: String) -> String {
    
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    
    let hashString = hashedData.compactMap {
        
        return String(format: "%02x", $0)
        
    }.joined()
    
    return hashString
    
}
