//
//  ChatUIView.swift
//  WeText
//
//  Created by Santhosh Srinivas on 15/12/21.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import SDWebImageSwiftUI

//extension Array where Element : Equatable{
//    mutating func distinct(){
//        var uniqueElems: [Element] = []
//        for elem in self{
//            if !uniqueElems.contains(elem){
//                uniqueElems.append(elem)
//            }
//        }
//        self = uniqueElems
//    }
//}
class ChatLogViewModel: ObservableObject {

    @Published var chatText = ""
    @Published var errorMessage = ""

    @Published var chatMessages = [ChatMessage]()
    var firestoreListener: ListenerRegistration?
    var chatUser: ChatUser?
    
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        fetchMessages()
    }

    func fetchMessages(){
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        firestoreListener?.remove()
        chatMessages.removeAll()
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                        if let error = error{
                            self.errorMessage = "Failed to listen to Messages \(error)"
                            print(error)
                            return
                        }
                        querySnapshot?.documentChanges.forEach({ change in
                            if change.type == .added {
                                do {
                                    if let cm = try change.document.data(as: ChatMessage.self) {
                                        self.chatMessages.append(cm)
                                        print("Appending chatMessage in ChatLogView: \(Date())")
                                    }
                                } catch {
                                    print("Failed to decode message: \(error)")
                                }
                            }
                        })
                        DispatchQueue.main.async{
                        self.count += 1
                        }
                    }
            }
    func handleSend() {
        print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }

        guard let toId = chatUser?.uid else { return }

        let document = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()

        let msg = ChatMessage(id: nil, fromId: fromId, toId: toId, text: chatText, timestamp: Date())
        
        try? document.setData(from: msg) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            
            print("Successfully saved current user sending message")
            self.recentMessage()
            
            self.chatText = ""
            self.count += 1
        }

        let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()

        try? recipientMessageDocument.setData(from: msg) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }

            print("Recipient saved message as well")
//            self.chatText = ""
        }
    }
    private func recentMessage(){
        guard let chatUser = chatUser else {
            return
        }

        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else { return }
        guard let toId = self.chatUser?.uid
        else { return }
//        FirebaseManager.shared.firestore.collection(FirebaseConstants.recentMessages).document(uid).collection(FirebaseConstants.messages).document(toId)
//
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .document(toId)
        
        let data = [
                    FirebaseConstants.timestamp: Timestamp(),
                    FirebaseConstants.text: self.chatText,
                    FirebaseConstants.fromId: uid,
                    FirebaseConstants.toId: toId,
//                    FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
                    FirebaseConstants.uName : chatUser.uName,
//                    FirebaseConstants.active: chatUser.active
                ] as [String : Any]
        
        document.setData(data){ error in
                    if let error = error {
                        self.errorMessage = "Failed to save recent message: \(error)"
                        print("Failed to save recent message: \(error)")
                        return
                    }
                }
        
        guard let currentUser = FirebaseManager.shared.currentUser
        else { return }
        let recipientRecentMessageDictionary = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
//            FirebaseConstants.profileImageUrl: currentUser.profileImageUrl,
            FirebaseConstants.uName: currentUser.uName
        ] as [String : Any]

        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(toId)
            .collection(FirebaseConstants.messages)
            .document(currentUser.uid)
            .setData(recipientRecentMessageDictionary) { error in
                if let error = error {
                    print("Failed to save recipient recent message: \(error)")
                    return
                }
            }
    }
    @Published var count = 0
    
    func getSectionMessages(for chat: ChatMessage) -> [[ChatMessage]]{
        var li = [String]()
        var res = [[ChatMessage]]()
        var tmp = [ChatMessage]()
        for message in chatMessages {
            if let firstMsg = tmp.first{
                let daysBetween = firstMsg.timestamp.daysBetween(date: message.timestamp)
                if daysBetween <= 1{
////                    res.append(tmp)
//                    tmp.removeAll()
//                    tmp.append(message)
//                    print("MESSAGE: ", message.timestamp.descriptiveString())

                    if li.contains(message.timestamp.descriptiveString()){
                        continue
                    } else{
                        li.append(message.timestamp.descriptiveString())
                        tmp.removeAll()
                        tmp.append(message)
                    }
//                    print(li)
//                    print(li.distinct())
//                    tmp.distinct()
                } else{
//                    res.append(tmp)
                    if li.contains(message.timestamp.descriptiveString()){
                        continue
                    } else{
                        li.append(message.timestamp.descriptiveString())
//                        tmp.removeAll()
                        tmp.append(message)
                    }
//                    tmp.append(message)
//                    li.append(message.timestamp.descriptiveString())
//                    print(li)
//                    print(li.distinct())

//                    tmp.distinct()
                }
            } else{
//                res.append(tmp)
                tmp.append(message)
//                li.append(message.timestamp.descriptiveString())
//                    print(li)
//                print(li.distinct())
//                tmp.distinct()
            }
        }
        res.append(tmp)
//        print("RES:" ,res)
////        print("TMP:",tmp)
////        let reduce = res.distinct()
//        print("LIST", li)
        return res
    }

}

struct ChatLogView: View {

//    let chatUser: ChatUser?
//
//    init(chatUser : ChatUser?){
//
//        self.chatUser = chatUser
//        self.vm = .init(chatUser: chatUser)
//    }
       //  @State var chatText = ""
    @ObservedObject var vm: ChatLogViewModel
    @State var text = ""
    @State var isEditing = false
    @State var show = false
//    @State var message: ChatMessage
//    @FocusState private var textIsFocussed: Bool

//    @State var text = "good morning"
        var body: some View {
            VStack{
                
//                WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
//                    .resizable()
//                    .scaledToFill().frame(width: 128, height: 64)
//                    .clipped()
//                    .cornerRadius(64)
//                    .overlay(RoundedRectangle(cornerRadius: 44) .stroke(.black, lineWidth: 1))
//                    .shadow(color: .black, radius: 2.5)
//                SearchBarInChat(vm: vm , text: $text)
//                Text("\(vm.chatUser?.uName ?? "") was last active x mins ago")
                ZStack{
                    messagesView
                    Text(vm.errorMessage)
                    
//                ZStack {
//                    VStack(spacing: 0) {
//                        Spacer()
//                        chatBottomBar
//                            .background(Color.white.ignoresSafeArea())
                }
//                .padding(.vertical,8)
//                .barTintColor(Color("Color1"))
//                .navigationTitle(setTitle("\(vm.chatUser?.uName ?? "")", andImage: (named: "\(vm.chatUser?.profileImageUrl)")))
//                .navigationTitle("\(vm.chatUser?.uName ?? "")")
//                .navigationBarHidden(true)
                .toolbar{
//                    ToolbarItemGroup(placement: .navigationBarLeading) {
////                        Image("\(vm.chatUser?.profileImageUrl ?? "")")
//                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
//                        Spacer()
                        SearchBarInChat(vm: vm , text: $text)
//                        Spacer()
//                            .padding(.vertical,20)
                    }
                    
                }
//                .padding()
//                    .navigationBarTitleDisplayMode(.inline)
                    .onDisappear{
                        vm.firestoreListener?.remove()
                    }
                    .navigationBarItems(trailing: Button{
                        vm.count += 1
                    }label: {
                        //Text("Count: \(vm.count)")
                    })
                
            }
        }
//    @State var li = [String]()
        private var messagesView: some View {
            
            ScrollView {
                ScrollViewReader{  scrollViewProxy in
                    VStack{
//                        let message: ChatMessage
//
                        
                        ForEach(vm.chatMessages.filter({
                            "\($0)".contains(text) || text.isEmpty})){ message in
//                            let sectionMsgs = vm.getSectionMessages(for: message)
//                            ForEach(sectionMsgs.indices, id: \.self){ sectionIndex in
//                                let messages = sectionMsgs[sectionIndex]
//                                Section(header: Text("\(message.timestamp.descriptiveString())")) {
//                                    displayDate(message.timestamp.descriptiveString())
                                    MessageView(message: message)
//                                }
//                            }

                            
                            
                        }
                        HStack{ Spacer() }
                        .id("Empty")
                    }
                    .onReceive(vm.$count){ _ in
                        withAnimation(.easeOut(duration: 0.5)){
                        scrollViewProxy.scrollTo("Empty", anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color("Color2"))

//            .background(Color(.init(white: 0.90, alpha: 1)))//.systemBackground)) //(.init(white: 0.90, alpha: 1)))
            .safeAreaInset(edge: .bottom){
                chatBottomBar
                    .background(Color(.systemBackground)) //.ignoresSafeArea())
//                    .offset(y: 25)
            }

        }
    
        private var chatBottomBar: some View {
            VStack{
                HStack(spacing: 16) {
//                    Button{
//
//                    } label: {
//                        Image(systemName: "paperclip.circle.fill")
//                            .font(.system(size: 40))
//                            .foregroundColor(Color(.darkGray))
//                    }
                        
//                    HStack {
//                        DescriptionPlaceholder()
                        TextField("Message", text: $vm.chatText)
//                            .frame(height: 40)
//                            .opacity(vm.chatText.isEmpty ? 0.5 : 1)
//                            .background(Color("Color1"))
////                            .padding(.horizontal,40)
//                            .padding(.vertical, 20)
////                            .padding()
////                            .focused($textIsFocussed)
//                            .cornerRadius(100)
                            .padding(.horizontal,14)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
//                    }
//                    .cornerRadius(35)
                    .frame(height: 43)

                    Button {
                        vm.handleSend()
                    } label: {
                        Image(systemName: "paperplane.fill")
//                            .frame(width: 20, height: 20, alignment: .center)
                            .cornerRadius(8)
                            .foregroundColor(Color("NavBarColor1"))
                            .offset(x:-8)
//                            .cornerRadius(15)
                            .frame(width: 20, height: 20, alignment: .center)
//                            .cornerRadius(8)
//                            .background(Color("Color1"))
                    }
//                    .background(Color("Color1"))
//                    .buttonStyle(.bordered)
//                                                    .tint(Color("NavBarColor1"))
//                    .cornerRadius(15)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
//                    .background(Color.blue)
                    
                }
//                .background(Color("Color1"))
                .padding(.horizontal)
                .padding(.vertical, 8)
                .cornerRadius(15)
            }
            .ignoresSafeArea()
        }
}
struct MessageView: View{
    let message: ChatMessage
    var body: some View{
        VStack{
//            Text("\(message.timestamp.descriptiveString())")//, style: .time)")
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid{
                VStack{
                    HStack {
                        Spacer()
                        VStack(alignment: .leading){
                            Text(message.text)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
//                            VStack(alignment: .){
                            HStack(alignment: .lastTextBaseline){
                                    Text("\(message.timestamp.descriptiveString1())")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(.lightGray))
                                        .multilineTextAlignment(.trailing)
                                    Text(message.timestamp, style: .time)
                                        .font(.caption2)
                                        .foregroundColor(Color(.lightGray))
                                        .multilineTextAlignment(.trailing)
                                }
//                            }
                        }
                        .padding(.bottom,4)
                        .padding(.top, 8)
                        .padding(.trailing,12)
                        .padding(.leading,12)
                        .background(Color("Color"))//Color(red: 225/255, green: 247/255, blue: 203/255))
                        .shadow(color: Color("Color"), radius: 2)
                        .cornerRadius(12)
                    }
                }
                
            } else {
                HStack {
                    // Spacer()
                    VStack(alignment: .leading) {
                        Text(message.text)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
//                        VStack(alignment: .trailing) {
                            HStack(alignment: .firstTextBaseline){
                                Text("\(message.timestamp.descriptiveString1())")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.lightGray))
                                    .multilineTextAlignment(.trailing)
                                Text(message.timestamp, style: .time)
                                    .font(.caption2)
                                    .foregroundColor(Color(.lightGray))
                                    .multilineTextAlignment(.trailing)
                            }
//                        }
                    }
                    .padding(.bottom,4)
                    .padding(.top, 8)
                    .padding(.horizontal,12)
                    .background(Color("Color1"))
//                    .shadow(color: .primary, radius: 10)
                    .cornerRadius(12)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
//        .padding(.top, 8)
    }
}
//private struct DescriptionPlaceholder: View {
//    var body: some View {
//        HStack {
//            Text("Message")
//                .foregroundColor(.primary)
//                .font(.system(size: 17))
//                .padding(.leading, 5)
//                .padding(.top, -4)
//            Spacer()
//        }
//    }
//}

struct ChatUIView_Previews: PreviewProvider {
    static var previews: some View {
        //NavigationView{
            //ChatLogView(chatUser: .init(data: ["uid" : "r3rme2IKBJUJzGiv750wRuH9xps2" , "email" : "qwerty@gmail.com"]))
        MainMsgView()
            .preferredColorScheme(.light)
        //}
    }
}
