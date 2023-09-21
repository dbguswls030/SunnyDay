//
//  BoardModel.swift
//  Gardener
//
//  Created by 유현진 on 2023/09/13.
//

import Foundation
import FirebaseFirestore

class BoardModel{
    var category: String
    var title: String
    var contents: String
    var date: Date
    var imageUrls: [String]
    var uid: String
    
    init(category: String, title: String, contents: String, date: Date, imageUrls: [String], uid: String) {
        self.category = category
        self.title = title
        self.contents = contents
        self.date = date
        self.imageUrls = imageUrls
        self.uid = uid
    }
}
