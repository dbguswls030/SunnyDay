//
//  TestCommentModel.swift
//  Gardener
//
//  Created by 유현진 on 12/17/23.
//

import Foundation

struct CommentModel: Codable{
    let commentId: Int
    let date: Date
    let content: String
    let dept: Int
    let userId: String
    let profileImageURL: String
    let nickName: String
    let isHidden: Bool
    let isEmptyReply: Bool
    
    init(commentId: Int, content: String, dept: Int, userId: String, profileImageURL: String, nickName: String){
        self.commentId = commentId
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
        self.commentId = try container.decode(Int.self, forKey: .commentId)
        self.nickName = try container.decode(String.self, forKey: .nickName)
        self.profileImageURL = try container.decode(String.self, forKey: .profileImageURL)
        self.isHidden = try container.decode(Bool.self, forKey: .isHidden)
        self.isEmptyReply = try container.decode(Bool.self, forKey: .isEmptyReply)
    }
    
    enum CodingKeys: String, CodingKey{
        case date
        case content
        case dept
        case userId
        case commentId
        case nickName
        case profileImageURL
        case isHidden
        case isEmptyReply
    }
}
