//
//  MainMsgView.swift
//  WeText
//
//  Created by Santhosh Srinivas on 14/12/21.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestoreSwift
import Firebase

class MainMessagesViewModel: ObservableObject {

    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut = false

    init() {
            DispatchQueue.main.async {
                self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
            
            }
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    @Published var recentMessageArray = [RecentMessage]()
    private var firestoreListener: ListenerRegistration?
    
    func fetchRecentMessages(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else { return }
        firestoreListener?.remove()
        self.recentMessageArray.removeAll()
        
        
        firestoreListener =  FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener{ querySnapshot, error in
                if let error = error{
                    self.errorMessage = "Failed to listen to recent message \(error)"
                    print(error)
                    return
                }
                querySnapshot?.documentChanges.forEach({
                    change in
                        let docId = change.document.documentID
                        if let index = self.recentMessageArray.firstIndex(where: {rm in
                            return rm.id == docId
                        })
                        {
                            self.recentMessageArray.remove(at: index)
                        }
                    do{
                        if let rm = try change.document.data(as: RecentMessage.self){
                            self.recentMessageArray.insert(rm, at: 0)
                        }
                    } catch{
                        print(error)
                    }
//                                            self.recentMessageArray.insert(.init(documentId: docId, data: change.document.data()), at: 0)
//                        self.recentMessageArray.append()
                })
            }
    }
    func fetchCurrentUser() {

        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }

        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }

            self.chatUser = try? snapshot?.data(as: ChatUser.self)
            FirebaseManager.shared.currentUser = self.chatUser
//            guard let data = snapshot?.data() else {
//                self.errorMessage = "No data found"
//                return
//
//            }
//            self.chatUser = .init(data: data)
        }
    }
    
    @Published var isCurrentlyLoggedOut = false
    
    func handleSignOut(){
        isUserCurrentlyLoggedOut.toggle()
                 try? FirebaseManager.shared.auth.signOut()
//        userData.isActive = "Offline"
    }

}

struct MainMsgView: View {
    
    @ObservedObject var vm = MainMessagesViewModel()
    @State var shouldShowLogOutOptions = false
    @State var shouldNavigateToChatLogView = false
    @State var scrollViewOffset: CGFloat = 0
    @State var staartOffset: CGFloat = 0
    @State var isScrollToTop = false
    private var chatLogViewModel1 = ChatLogViewModel(chatUser: nil)
//    @State var status = false
//    @State var userStatus = ""
//    
//    if status {
//        userSatus = "Online"
//    } else{
//        userSatus = "Offline"
//    }
    var body: some View {
//        ScrollViewReader{ proxyReader in
//            ScrollView(.vertical, showsIndicators: false, content: {
                NavigationView{
                    VStack{
                        customNavBar
                        ScrollView{
                            VStack{
                                ForEach (vm.recentMessageArray){ recentMessage in
                                    Button {
                                        let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
                                        
                                        self.chatUser = .init(id: uid, uid: uid, uName: recentMessage.uName)//, isActive: "Online")
                                        //.init(data:[FirebaseConstants.uName : recentMessage.uName, FirebaseConstants.uid : uid])
                                        self.chatLogViewModel1.chatUser = self.chatUser
                                        self.chatLogViewModel1.fetchMessages()
                                        self.shouldNavigateToChatLogView.toggle()
                                } label: {
                                    HStack(spacing: 14){
                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size: 42))
        //                                    .padding(.vertical,5)
                                            .foregroundColor(Color("Color3"))
                                            .offset(x:8.5)
        //                                    .overlay(RoundedRectangle(cornerRadius: 20)
        //                                                .stroke(Color("Color3"), lineWidth: 2))
        //                                WebImage(url: URL(string: recentMessage.profileImageUrl))
        //                                    .resizable()
        //                                    .scaledToFill().frame(width: 64, height: 64)
        //                                    .clipped()
        //                                    .cornerRadius(64)
        //                                    .overlay(RoundedRectangle(cornerRadius: 44) .stroke(.primary, lineWidth: 2))
                                        VStack(alignment: .leading){
                                            HStack{
                                                Text(recentMessage.uName)
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(Color(.label))
                                                    .offset(x: 20)
                                                Spacer()
                                                Text(recentMessage.timestamp.descriptiveString())
                //                                    .frame(alignment: .top)
                                                    .offset(x:-5)
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(Color("InvertNavBarColor"))
                                            }
                                            Text(recentMessage.text)
                                                .lineLimit(2)
                                                .foregroundColor(Color(.lightGray))
                                                .multilineTextAlignment(.leading)
                                                .offset(x: 20)
                                                .padding(.trailing , 20)
                                                
                                        }
        //                                Spacer()
        //                                Text(recentMessage.timeAgo)
        ////                                    .frame(alignment: .top)
        //                                    .offset(x:-5, y:-10)
        //                                    .font(.system(size: 14, weight: .semibold))
        //                                    .foregroundColor(Color("InvertNavBarColor"))//Color(red: 250/255, green: 115/255, blue: 87/255))
        //                                    .multilineTextAlignment(.top)
                                    }
                                    .padding(.vertical,8)
                                }
                                Divider()
                                    .padding(.vertical,1)
                            }
                            .padding(.horizontal)
                        }
        //                .padding(.bottom,20)
                    }
                        NavigationLink("", isActive: $shouldNavigateToChatLogView){
                            
                            ChatLogView(vm: chatLogViewModel1)
                            
                        }
        //                .foregroundColor(Color("InvertNavBarColor"))

                    }
                    .overlay(newMessageButton,alignment: .bottom)
                    .navigationBarHidden(true)
        //            .padding()
                }
                .accentColor(Color("NavBarColor1"))
                
                
                .id("GO_TO_TOP")
//                .overlay(
//                    GeometryReader{ proxy -> Color in
////                    GeometryReader{proxy -> Color in
//                        DispatchQueue.main.async{
//                            if staartOffset == 0{
//                                self.staartOffset = proxy.frame(in: .global).minY
//                            }
//                            let offset = proxy.frame(in: .global).minY
//                            self.scrollViewOffset = offset - staartOffset
//                            print(self.scrollViewOffset)
//                        }
//                    })
//            })
            
//        }
        
    }
    private var customNavBar: some View{
        VStack{
            HStack{
                    Text("PiM")
                        .multilineTextAlignment(.leading)
                        .padding(.trailing)
                        .foregroundColor(Color("NavBarText"))
                        .padding(.horizontal)
                        .padding(.vertical, 20)
                        .offset(x:-10)
                Spacer()
                VStack(alignment: .trailing){
                    HStack(spacing: 2){
                         Text(vm.chatUser?.uName ?? "")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("NavBarText"))
//                            .offset(x:110)
    //                        .multilineTextAlignment(.trailing)
    //                }
//                    Spacer()
                    Button {
                        shouldShowLogOutOptions.toggle()
                        } label: {
                            Image(systemName: "gear")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color("InvertNavBarColor"))
                            
                        }
                    }
                }
                    
        }
//            .padding(.vertical,8)
            .padding()
                .font(.system(size: 30, weight: .heavy))
                .frame(maxWidth: .infinity,maxHeight: 60.0, alignment: .leading)
                
                .background(Color("NavBarColor"))
//                Image(systemName: "person.fill")
//                    .font(.system(size: 32))
//                    .padding()
//                    .foregroundColor(.primary)
//                    .overlay(RoundedRectangle(cornerRadius: 44)
//                                .stroke(.primary, lineWidth: 1))
//                WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 60, height: 70)
//                    .clipped()
//                    .cornerRadius(44)
//                    .overlay(RoundedRectangle(cornerRadius: 44) .stroke(.primary, lineWidth: 3))
//                    .shadow(color: Color(.darkGray) , radius: 10)
                
//                VStack(alignment: .leading, spacing: 2){
//
//                    //Text("\(vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? "")")
//                     Text(vm.chatUser?.uName ?? "")
//                        .font(.system(size: 28, weight: .semibold))
//                    HStack{
//                        Circle()
//                            .foregroundColor(.green)
//                            .frame(width: 14, height: 12, alignment: .leading)
//                        Text("Online")
//                            .font(.system(size: 12))
//                            .foregroundColor(.gray)
//                    }
//                }
                
            
            .actionSheet(isPresented: $shouldShowLogOutOptions) {
                .init(title: Text("Settings"), message: Text("Do you want to switch Accounts?"), buttons: [
                    .destructive(Text("Sign Out"), action: {
                        print("signing out")
                        vm.handleSignOut()
                    }),
                        .cancel()
                ])
            }
            .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
                LoginView(loginComplete: {
                    self.vm.isUserCurrentlyLoggedOut = false
                    self.vm.fetchCurrentUser()
                    self.vm.fetchRecentMessages()
                }
            )}
//            .padding(.bottom,8)
        }
    }
    
    @State var newMsgScreen = false
    
    private var newMessageButton: some View{
        Button {
                newMsgScreen.toggle()
            } label: {
                HStack {
                    Spacer()
                    Text("+ New Message")
                        .font(.system(size: 20, weight: .bold))
                        Spacer()
                    }
                .foregroundColor(Color("NavBarText"))
                .padding(.vertical)
                    .background(Color("NavBarColor"))
                    .cornerRadius(24)
                    .padding(.horizontal)
                    .shadow(radius: 16)
            }
//            .alignmentGuide(.trailing)
            .fullScreenCover(isPresented: $newMsgScreen, onDismiss: nil){
                NewMessageView(selectNewUser: { user in
//                    print(user.email)
                    self.shouldNavigateToChatLogView.toggle()
                    self.chatUser = user
                    self.chatLogViewModel1.chatUser = user
                    self.chatLogViewModel1.fetchMessages()
            })
        }
//            .accentColor(Color("NavBarColor1"))
        
    }
        @State var chatUser: ChatUser?
}


struct MainMsgView_Previews: PreviewProvider {
    static var previews: some View {
        MainMsgView()
            .preferredColorScheme(.dark)
    }
}
