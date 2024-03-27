//
//  ChatMemberModel.swift
//  Gardener
//
//  Created by 유현진 on 2/11/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum ChatClass{
    case master
    case manager
    case member
}

struct ChatMemberModel: Codable{
    var uid: String
    var level: Int
}

struct TestChatMemberModel: Codable{
    @DocumentID var uid: String?
    var level: Int
    
    init(level: Int, uid: String) {
        self.level = level
        self.uid = uid
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._uid = try container.decode(DocumentID<String>.self, forKey: .uid)
        self.level = try container.decode(Int.self, forKey: .level)
    }
    
    enum CodingKeys: String, CodingKey{
        case level
        case uid
    }
}
