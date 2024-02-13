//
//  ChatModel.swift
//  Gardener
//
//  Created by 유현진 on 1/26/24.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct ChatRoomModel: Codable{
    var roomId: String // DocumentId
    var title: String
    var subTitle: String
    var members: [ChatMemberModel]
    var thumbnailURL: String
    var date: Date
    
    init(title: String, subTitle: String, members: [ChatMemberModel]) {
        self.title = title
        self.subTitle = subTitle
        self.members = members
        self.date = Date()
        self.thumbnailURL = ""
        self.roomId = UUID().uuidString + String(Date().timeIntervalSince1970)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.subTitle = try container.decode(String.self, forKey: .subTitle)
        self.members = try container.decode([ChatMemberModel].self, forKey: .members)
        self.date = try container.decode(Date.self, forKey: .date)
        self.thumbnailURL = try container.decode(String.self, forKey: .thumbnailURL)
        self.roomId = try container.decode(String.self, forKey: .roomId)
    }
    
    
    enum CodingKeys: String, CodingKey{
        case title
        case subTitle
        case members
        case roomId
        case date
        case thumbnailURL
    }
}
