//
//  CreateBoard.swift
//  Gardener
//
//  Created by 유현진 on 2023/09/20.
//

import Foundation
import UIKit

class CreateBoard{
    let category: String
    let title: String
    let contents: String
    let images: [UIImage]
    let date: Date
    let userInfo: UserModel
    
    init(category: String, title: String, contents: String, images: [UIImage], date: Date, userInfo: UserModel) {
        self.category = category
        self.title = title
        self.contents = contents
        self.images = images
        self.date = date
        self.userInfo = userInfo
    }
    
}
