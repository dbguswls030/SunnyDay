//
//  BoardModel.swift
//  Gardener
//
//  Created by 유현진 on 2023/09/13.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct BoardModel: Codable{
    @DocumentID var documentId: String?
    var boardId: String
    var category: String
    var title: String
    var contents: String
    var date: Date
    var contentImageURLs: [String]
    var uid: String
    var nickName: String
    var profileImageURL: String
    var likeCount: Int
    var commentCount: Int
    var isDelete: Bool
    
    init(boardId: String, category: String, title: String, contents: String, uid: String, nickName: String, profileImageURL: String, contentImageURLs: [String]) {
        self.boardId = boardId
        self.category = category
        self.title = title
        self.contents = contents
        self.date = Date()
        self.contentImageURLs = contentImageURLs
        self.uid = uid
        self.nickName = nickName
        self.profileImageURL = profileImageURL
        self.likeCount = 0
        self.commentCount = 0
        self.isDelete = false
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.category = try container.decode(String.self, forKey: .category)
        self.contents = try container.decode(String.self, forKey: .contents)
        self.date = try container.decode(Date.self, forKey: .date)
        self.contentImageURLs = try container.decode([String].self, forKey: .contentImageURLs)
        self.uid = try container.decode(String.self, forKey: .uid)
        self.boardId = try container.decode(String.self, forKey: .boardId)
        self.nickName = try container.decode(String.self, forKey: .nickName)
        self.profileImageURL = try container.decode(String.self, forKey: .profileImageURL)
        self.likeCount = try container.decode(Int.self, forKey: .likeCount)
        self.boardId = try container.decode(String.self, forKey: .boardId)
        self.commentCount = try container.decode(Int.self, forKey: .commentCount)
        self.isDelete = try container.decode(Bool.self, forKey: .isDelete)
        _documentId = try container.decode(DocumentID<String>.self, forKey: .documentId)
    }
    
    enum CodingKeys: String, CodingKey{
        case title
        case category
        case contents
        case date
        case contentImageURLs
        case uid
        case boardId
        case nickName
        case profileImageURL
        case likeCount
        case commentCount
        case isDelete
        case documentId
    }
}
