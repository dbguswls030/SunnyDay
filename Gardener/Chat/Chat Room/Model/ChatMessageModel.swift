//
//  ChatModel.swift
//  Gardener
//
//  Created by 유현진 on 2/1/24.
//

import Foundation

struct ChatMessageModel: Codable{
    var uid: String
    var message: String
    var date: Date
    
    enum CodingKeys: String, CodingKey{
        case uid
        case message
        case date
    }
}
