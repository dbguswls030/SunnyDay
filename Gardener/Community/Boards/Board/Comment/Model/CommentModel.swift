//
//  TestCommentModel.swift
//  Gardener
//
//  Created by 유현진 on 12/17/23.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct CommentModel: Codable{
    @DocumentID var documentId: String?
    let parentId: Int
    let date: Date
    var content: String
    let dept: Int
    let userId: String
    var profileImageURL: String
    var nickName: String
    let isHidden: Bool
    let isEmptyReply: Bool
    
    init(parentId: Int, content: String, dept: Int, userId: String, profileImageURL: String, nickName: String){
        self.parentId = parentId
        self.content = content
        self.dept = dept
        self.date = Date()
        self.userId = userId
        self.profileImageURL = profileImageURL
        self.nickName = nickName
        self.isHidden = false
        self.isEmptyReply = true
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try container.decode(Date.self, forKey: .date)
        self.content = try container.decode(String.self, forKey: .content)
        self.dept = try container.decode(Int.self, forKey: .dept)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.parentId = try container.decode(Int.self, forKey: .parentId)
        self.nickName = try container.decode(String.self, forKey: .nickName)
        self.profileImageURL = try container.decode(String.self, forKey: .profileImageURL)
        self.isHidden = try container.decode(Bool.self, forKey: .isHidden)
        self.isEmptyReply = try container.decode(Bool.self, forKey: .isEmptyReply)  
        _documentId = try container.decode(DocumentID<String>.self, forKey: .documentId)
    }
    
    enum CodingKeys: String, CodingKey{
        case date
        case content
        case dept
        case userId
        case parentId
        case nickName
        case profileImageURL
        case isHidden
        case isEmptyReply
        case documentId
    }
}
