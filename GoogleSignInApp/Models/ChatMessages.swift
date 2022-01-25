//
//  ChatMessages.swift
//  WeText
//
//  Created by Santhosh Srinivas on 15/12/21.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable{//}, Equatable, Hashable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let timestamp: Date
//    var timeAgo: String {
//        let formatter = RelativeDateTimeFormatter()
//        formatter.unitsStyle = .abbreviated
//        return formatter.localizedString(for: timestamp, relativeTo: Date())
//    }

}

//struct Chat: Identifiable{
//    var id: String?
//    var messages: Message
//    
//}
//struct Message: Identifiable{
//    let id: String?
//    let timestamp: Date
//    let text: String
//    
//    init(_ text: String, timestamp: Date){
//        self.timestamp = timestamp
//        self.text = text
//    }
//    init(_ text: String){
//        self.init(text, timestamp: Date())
//    }
//}
