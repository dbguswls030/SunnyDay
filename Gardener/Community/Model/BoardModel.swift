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
    var images: [UIImage]
    var uid: String
    
//    enum CodingKeys: String, CodingKey{
//        case category, contents, uid //, date
//        case images = "imageUrl"
//    }
    init(category: String, title: String, contents: String, date: Date, images: [UIImage], uid: String) {
        self.category = category
        self.title = title
        self.contents = contents
        self.date = date
        self.images = images
        self.uid = uid
    }
}
