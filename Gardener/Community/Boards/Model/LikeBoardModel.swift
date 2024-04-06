//
//  LikeBoardModel.swift
//  Gardener
//
//  Created by 유현진 on 1/7/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct LikeBoardModel: Codable{
    @DocumentID var likeBoardId: String?
    var userId: String
    
    enum CodingKeys: String, CodingKey{
        case likeBoardId
        case userId
    }
    
    init(userId: String){
        self.userId = userId
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._likeBoardId = try container.decode(DocumentID<String>.self, forKey: .likeBoardId)
        self.userId = try container.decode(String.self, forKey: .userId)
    }
}
