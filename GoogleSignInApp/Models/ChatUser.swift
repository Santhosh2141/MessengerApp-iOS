//
//  ChatUser.swift
//  WeText
//
//  Created by Santhosh Srinivas on 15/12/21.
//

import FirebaseFirestoreSwift

struct ChatUser: Identifiable, Codable {
    
    @DocumentID var id: String?//{
//        uid
//    }
//    var username: String {
//        email.components(separatedBy: "@").first ?? email
//    }
    let uid, uName : String
//    let profileImageUrl: String
//    init(data: [String: Any]){
//        self.uid = data["uid"] as? String ?? ""
////        self.email = data["email"] as? String ?? ""
////        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
//        self.uName = data["uName"] as? String ?? ""
//        self.active = data["active"] as? String ?? ""
//    }
}


