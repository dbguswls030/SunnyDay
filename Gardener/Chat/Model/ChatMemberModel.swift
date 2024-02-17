//
//  ChatMemberModel.swift
//  Gardener
//
//  Created by 유현진 on 2/11/24.
//

import Foundation

enum ChatClass{
    case master
    case manager
    case member
}

struct ChatMemberModel: Codable{
    var uid: String
    var level: Int
}
