//
//  ChatRoomModel.swift
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
    var thumbnailURL: String
    var date: Date
    var likeCount: Int
    var memberCount: Int
    
    init(title: String, subTitle: String) {
        self.title = title
        self.subTitle = subTitle
        self.date = Date()
        self.thumbnailURL = ""
        self.likeCount = 0
        self.memberCount = 0
        self.roomId = UUID().uuidString + String(Date().timeIntervalSince1970)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.subTitle = try container.decode(String.self, forKey: .subTitle)
        self.date = try container.decode(Date.self, forKey: .date)
        self.thumbnailURL = try container.decode(String.self, forKey: .thumbnailURL)
        self.roomId = try container.decode(String.self, forKey: .roomId)
        self.likeCount = try container.decode(Int.self, forKey: .likeCount)
        self.memberCount = try container.decode(Int.self, forKey: .memberCount)
    }
    
    
    enum CodingKeys: String, CodingKey{
        case title
        case subTitle
        case roomId
        case date
        case thumbnailURL
        case likeCount
        case memberCount
    }
}
