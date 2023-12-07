//
//  UserModel.swift
//  Gardener
//
//  Created by 유현진 on 12/6/23.
//

import Foundation
class UserModel{
    let nickName: String
    let profileImageURL: String
    
    init(nickName: String, profileImageURL: String) {
        self.nickName = nickName
        self.profileImageURL = profileImageURL
    }
}
