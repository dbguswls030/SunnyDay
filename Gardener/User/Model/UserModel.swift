//
//  UserModel.swift
//  Gardener
//
//  Created by 유현진 on 12/6/23.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

class UserModel: Codable{
    let nickName: String
    let profileImageURL: String
    let likeBoards: [String]
    let likeComments: [String]
    let participatedChat: [String]
    
    init(nickName: String, profileImageURL: String) {
        self.nickName = nickName
        self.profileImageURL = profileImageURL
        self.likeBoards = []
        self.likeComments = []
        self.participatedChat = []
    }
    
    enum CodingKeys: String, CodingKey{
        case nickName
        case profileImageURL
        case likeBoards
        case likeComments
        case participatedChat
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nickName = try container.decode(String.self, forKey: .nickName)
        profileImageURL = try container.decode(String.self, forKey: .profileImageURL)
        likeBoards = try container.decode([String].self, forKey: .likeBoards)
        likeComments = try container.decode([String].self, forKey: .likeComments)
        participatedChat = try container.decode([String].self, forKey: .participatedChat)
    }

}
