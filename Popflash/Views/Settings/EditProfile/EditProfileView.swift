//
//  SkillGroupView.swift
//  SkillGroupView
//
//  Created by Seb Vidal on 29/07/2021.
//

import SwiftUI
import Kingfisher
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

struct EditProfileView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var displayName: String
    @State var rankSelection: String
    @State var profilePicture: String
    @State var inputImage: UIImage?
    @State var deleteAvatar = false
    
    var body: some View {
        
        NavigationView {
            
            ScrollView {
                
                ProfilePictureEditor(avatarURL: profilePicture,
                                     inputImage: $inputImage,
                                     deleteAvatarOnDismiss: $deleteAvatar)
                
                Divider()
                    .padding(.horizontal)
                
                DisplayNameEditor(displayName: $displayName)
                
                Divider()
                    .padding(.horizontal)
                
                RankGrid(selectedIndex: $rankSelection)
                
                Divider()
                    .padding(.horizontal)
                
                DeleteAccount(presentationMode: presentationMode)
                
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(
                
                leading:
                    
                    CancelButton(presentationMode: presentationMode),
                
                trailing:
                    
                    SaveButton(presentationMode: presentationMode,
                               rankSelection: $rankSelection,
                               displayName: $displayName,
                               inputImage: $inputImage,
                               deleteAvatar: $deleteAvatar)
                
            )
            
        }
        .interactiveDismissDisabled()
        
    }
    
}

private struct CancelButton: View {
    
    @Binding var presentationMode: PresentationMode
    
    var body: some View {
        
        Button(action: cancel) {
            
            Text("Cancel")
                .foregroundStyle(.blue)
            
        }
        
    }
    
    func cancel() {
        
        $presentationMode.wrappedValue.dismiss()
        
    }
    
}

private struct SaveButton: View {
    
    @Binding var presentationMode: PresentationMode
    @Binding var rankSelection: String
    @Binding var displayName: String
    @Binding var inputImage: UIImage?
    @Binding var deleteAvatar: Bool
    @State var showingAlert = false
    @State var alertID = 0
    
    var body: some View {
            
        Button(action: save) {
            
            Text("Save")
                .fontWeight(.bold)
                .foregroundStyle(.blue)
            
        }
        .alert(isPresented: $showingAlert) {
            
            switch alertID {
                
            case 3:
                
                return Alert(title: Text("Cannot Save Profile"),
                             message: Text("Please enter your preferred display name."),
                             dismissButton: .default(Text("OK")))
                
            case 2:
                
                return Alert(title: Text("Cannot Save Profile"),
                             message: Text("Please select your in-game rank."),
                             dismissButton: .default(Text("OK")))
                
            default:
                
                return Alert(title: Text("Cannot Save Profile"),
                             message: Text("Please enter your preferred display name and select your in-game rank."),
                             dismissButton: .default(Text("OK")))
                
            }
            
        }
        
    }
    
    func save() {
        
        if rankSelection == "" && displayName == "" {
            
            alertID = 1
            showingAlert = true
            
        } else if rankSelection == "" {
            
            alertID = 2
            showingAlert = true
            
        } else if displayName == "" {
            
            alertID = 3
            showingAlert = true
            
        } else {
            
            saveData()
            removeImage()
            $presentationMode.wrappedValue.dismiss()
            
        }
        
    }
    
    func saveData() {
        
        if let user = Auth.auth().currentUser {
            
            let db = Firestore.firestore()
            let ref = db.collection("users").document(user.uid)
            
            ref.setData(
                ["displayName": displayName,
                 "skillGroup": rankSelection],
                merge: true
            )
            
            uploadImage()
            
        }
        
    }
    
    func uploadImage() {

        if let user = Auth.auth().currentUser {
            
            let storage = Storage.storage()
            let ref = storage.reference().child("Avatars/\(user.uid).png")
            
            guard let selectedImage = inputImage else {
                
                return
                
            }
            
            let resizedImage = selectedImage.imageResized(to: CGSize(width: 65, height: 65))
            
            guard let data = resizedImage.pngData() else {
                
                return
                
            }
            
            ref.putData(data, metadata: nil) { (_, error) in
                
                ref.downloadURL { (url, error) in
                    
                    guard let downloadURL = url else {
                        
                        return
                        
                    }
                    
                    updateAvatarURL(url: downloadURL, user: user.uid)
                    
                }
                
            }
            
        }
        
    }
    
    func updateAvatarURL(url: URL, user: String) {
        
        let urlString = url.absoluteString
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user)
            
        ref.setData(
            ["avatar": urlString],
            merge: true
        )
        
    }
    
    func removeImage() {
        
        if !deleteAvatar {
            
            return
            
        }
        
        guard let user = Auth.auth().currentUser else {
            
            return
            
        }
        
        let uid = user.uid
        
        let storage = Storage.storage()
        let storageRef = storage.reference().child("Avatars/\(uid).png")
        
        storageRef.delete { error in
            
            if let error = error {
                
                print(error.localizedDescription)
                
            }
            
        }
        
        let db = Firestore.firestore()
        let dbRef = db.collection("users").document("\(uid)")
        
        dbRef.updateData(
            
            ["avatar": FieldValue.delete()]
            
        ) { error in
            
            if let error = error {
                
                print(error.localizedDescription)
                
            }
            
        }
        
    }
    
}

private struct ProfilePictureEditor: View {
    
    @State var avatarURL: String
    @Binding var inputImage: UIImage?
    @Binding var deleteAvatarOnDismiss: Bool
    
    @State private var image: Image?
    @State private var showingImagePicker = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text("Profile Picture")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.top)
            
            Text("Choose an image to upload as your profile picture.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                
                ZStack {
                    
                    Circle()
                        .frame(width: 65, height: 65)
                        .foregroundColor(.gray)
                    
                    Image(systemName: "camera.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .padding(.bottom, 2)
                    
                    if avatarURL != "" {
                        
                        KFImage(URL(string: avatarURL))
                            .resizable()
                            .frame(width: 65, height: 65)
                            
                        
                    }
                    
                    if let image = image {
                        
                        image
                            .resizable()
                            .frame(width: 65, height: 65)
                            .clipShape(Circle())
                        
                    }
                    
                }
                .clipShape(Circle())
                .contentShape(Circle())
                .contextMenu {
                    
                    Button(action: pickImage) {
                        
                        
                        Label("Upload Image", systemImage: "photo")
                        
                    }
                    
                    if avatarURL != "" || image != nil {
                        
                        Button(role: .destructive, action: removeImage) {
                            
                            Label("Remove Image", systemImage: "trash")
                            
                        }
                        
                    }
                    
                }
                .padding(.top, 12)
                .padding(.trailing, 16)
                
                Button(action: pickImage) {
                    
                    Text("Upload Image")
                    
                }
                .foregroundColor(.blue)
                .padding(.top, 8)
                
                Spacer()
                
            }
            
        }
        .padding(.leading, 16)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            
            ImagePicker(image: $inputImage)
                .edgesIgnoringSafeArea(.bottom)
            
        }
        
    }
    
    func pickImage() {
        
        showingImagePicker = true
        
    }
    
    func loadImage() {
        
        guard let inputImage = inputImage else {
            
            return
            
        }
        
        image = Image(uiImage: inputImage)
        
    }
    
    func removeImage() {
        
        deleteAvatarOnDismiss = true
        avatarURL = String()
        image = nil
        
    }
    
}

private struct DisplayNameEditor: View {
    
    @Binding var displayName: String
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text("Display Name")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.leading, 18)
            
            Text("Enter your display name.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.leading, 18)
            
            DisplayNameTextField(displayName: $displayName)
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 8)
            
        }
        
    }
    
}

private struct DisplayNameTextField: View {
    
    @Binding var displayName: String
    
    @State var isFocused = false
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .frame(height: 36)
                .foregroundColor(Color("Secondary_Search_Bar"))
            
            HStack(spacing: 0) {
                
                Text("Display Name")
                    .padding(.leading, 12)
                    .opacity(displayName.isEmpty ? 1 : 0)
                
                Spacer()
                
                if !displayName.isEmpty {
                    
                    Button {
                        
                        clear()
                        
                    } label: {
                        
                        Image(systemName: "multiply.circle.fill")
                        
                    }
                    .padding(.trailing, 6)
                    
                }
                
            }
            .foregroundColor(Color("Search_Bar_Icons"))
            
            TextField("", text: $displayName)
                .padding(.leading, 12)
                .padding(.trailing, displayName.isEmpty ? 0 : 31)
                .submitLabel(.done)
            
        }
        
    }
    
    func clear() {
        
        displayName = ""
        
    }
    
}

private struct RankGrid: View {
    
    @StateObject var skillGroupViewModel = SkillGroupViewModel()
    
    @Binding var selectedIndex: String
    
    let columns = [
        
        GridItem(.adaptive(minimum: 132))
        
    ]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text("Rank")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.top, 2)
                .padding(.leading, 18)
            
            Text("Select your in-game rank.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.leading, 18)
            
            LazyVGrid(columns: columns, spacing: 16) {
                
                ForEach(sortedSkillGroups(skills: skillGroupViewModel.skillGroups), id: \.self) { skillGroup in
                    
                    SkillGroupCell(skill: skillGroup,
                                   selectedIndex: $selectedIndex)
                    
                }
                
            }
            .padding(.horizontal, 12)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
        }
        .onAppear(perform: onAppear)
        
    }
    
    func sortedSkillGroups(skills: [SkillGroup]) -> [SkillGroup] {
        
        let filteredSkills = skills.filter {
            
            $0.skillGroup != "Unknown"
            
        }
        
        let sortedSkills = filteredSkills.sorted(by: {
            
            $0.id < $1.id
            
        })
        
        return sortedSkills
        
    }
    
    func onAppear() {
        
        if skillGroupViewModel.skillGroups.isEmpty {
            
            skillGroupViewModel.fetchData()
            
        }
        
    }
    
}

private struct SkillGroupCell: View {
    
    var skill: SkillGroup
    
    @Binding var selectedIndex: String
    
    var body: some View {
        
        Button {
            
            selectedIndex = skill.skillGroup
            
        } label: {
            
            ZStack(alignment: .top) {
                
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .frame(height: 162)
                    .foregroundColor(selected() ? Color("Selected_Blue") : Color("Secondary_Background"))
                    .cellShadow()
                    .animation(.easeInOut, value: selectedIndex)
                
                VStack {
                    
                    KFImage(URL(string: skill.icon))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100)
                    
                    Text(skill.skillGroup)
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 8)
                        .foregroundColor(Color("Headline"))
                    
                    Spacer()
                    
                    Text("\(skill.id) of 18")
                        .foregroundStyle(.secondary)
                    
                    
                }
                .padding(.vertical, 16)
                
            }
            
        }
        .padding(.horizontal, 4)
        .scaleEffect(selected() ? 1.085 : 1)
        .animation(.easeInOut(duration: 0.2), value: selectedIndex)
        .buttonStyle(.plain)
        
    }
    
    func selected() -> Bool {
        
        if selectedIndex == skill.skillGroup {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
}

private struct DeleteAccount: View {
    
    @Binding var presentationMode: PresentationMode
    
    @State private var showingActionSheet = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text("Delete Account")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.leading, 18)
            
            Text("Delete your account and associated data.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.leading, 18)
            
            Button(action: deleteAccountAction) {

                Text("Delete Account")
                    .foregroundColor(.red)
                    .padding(.vertical, 14)
                    .frame(width: UIScreen.screenWidth - 32)
                    .background(Color("Secondary_Background"))
                
            }
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .buttonStyle(RoundedTableCell())
            .padding(.vertical, 12)
            .padding(.horizontal)
            .cellShadow()
            .actionSheet(isPresented: $showingActionSheet) {
                
                ActionSheet(title: Text("Delete Account"),
                            message: Text("Are you sure you want to delete your Popflash account and all associated data?"),
                            buttons: [
                                .destructive(Text("Delete Account")) {
                                    
                                    deleteAccount()
                                    
                                },
                                .cancel()
                            ])
                
            }
            
        }
        
    }
    
    func deleteAccountAction() {
        
        showingActionSheet = true
        
    }
    
    func deleteAccount() {
        
        guard let user = Auth.auth().currentUser else {
            
            return
            
        }
        
        if user.isAnonymous {
            
            return
            
        }
        
        deleteUserDocument(for: user)
        deleteUserAvatar(for: user)
        signOut()
        
        presentationMode.dismiss()
        
    }
    
    func deleteUserDocument(for user: User) {
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user.uid)
        
        ref.delete { error in
            
            if let error = error {
                
                print(error.localizedDescription)
                
            }
            
        }
        
    }
    
    func deleteUserAvatar(for user: User) {
        
        let storage = Storage.storage()
        let ref = storage.reference().child("Avatars/\(user.uid).png")
        
        ref.delete { error in
            
            if let error = error {
                
                print(error.localizedDescription)
                
            }
            
        }
        
    }
    
    func signOut() {
        
        DispatchQueue.global(qos: .background).async {
            
            try? Auth.auth().signOut()
            
        }
        
        authenticateAnonymously()
        
    }
    
}
