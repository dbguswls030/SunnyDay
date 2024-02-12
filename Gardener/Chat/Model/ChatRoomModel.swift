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
    @DocumentID var roomId: String?
    var title: String
    var subTitle: String
    var members: [ChatMemberModel]
    var date: Date
    
    init(title: String, subTitle: String, members: [ChatMemberModel]) {
        self.title = title
        self.subTitle = subTitle
        self.members = members
        self.date = Date()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.subTitle = try container.decode(String.self, forKey: .subTitle)
        self.members = try container.decode([ChatMemberModel].self, forKey: .members)
        self.date = try container.decode(Date.self, forKey: .date)
        self._roomId = try container.decode(DocumentID<String>.self, forKey: .roomId)
    }
    
    
    enum CodingKeys: String, CodingKey{
        case title
        case subTitle
        case members
        case roomId
        case date
    }
}
