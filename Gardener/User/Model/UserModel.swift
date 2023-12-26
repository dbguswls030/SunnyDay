//
//  UserModel.swift
//  Gardener
//
//  Created by 유현진 on 12/6/23.
//

import Foundation
class UserModel: Codable{
    let nickName: String
    let profileImageURL: String
    let likeBoards = [String]()
    let likeComments = [String]()
    
    init(nickName: String, profileImageURL: String) {
        self.nickName = nickName
        self.profileImageURL = profileImageURL
    }
    
    enum CodingKeys: String, CodingKey{
        case nickName
        case profileImageURL
    }
    
//    required init(from decoder: Decoder) throws {
//        <#code#>
//    }
}
