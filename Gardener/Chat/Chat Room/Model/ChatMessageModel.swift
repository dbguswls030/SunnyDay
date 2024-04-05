//
//  ChatMessageModel.swift
//  Gardener
//
//  Created by 유현진 on 2/1/24.
//

import Foundation

struct ChatMessageModel: Codable{
    var uid: String
    var message: String
    var date: Date
    var isExpelled: Bool
    
    init(uid: String, message: String, date: Date) {
        self.uid = uid
        self.message = message
        self.date = date
        self.isExpelled = false
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = try container.decode(String.self, forKey: .uid)
        self.message = try container.decode(String.self, forKey: .message)
        self.date = try container.decode(Date.self, forKey: .date)
        self.isExpelled = try container.decode(Bool.self, forKey: .isExpelled)
    }
    
    enum CodingKeys: String, CodingKey{
        case uid
        case message
        case date
        case isExpelled
    }
}
