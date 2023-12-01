//
//  CommentModel.swift
//  Gardener
//
//  Created by 유현진 on 12/2/23.
//

import Foundation

class CommentModel{
    var date: Date
    var content: String
    var dept: Int
    var userId: String
    var commentId: Int
    
    init(date: Date, content: String, dept: Int, userId: String, commentId: Int) {
        self.date = date
        self.content = content
        self.dept = dept
        self.userId = userId
        self.commentId = commentId
    }
}
