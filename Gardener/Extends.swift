//
//  Extends.swift
//  Gardener
//
//  Created by 유현진 on 2023/10/25.
//

import Foundation
import UIKit
import Kingfisher
import FirebaseStorage

extension UIImageView{
    func setImage(url: String){
        let cache = ImageCache.default
        cache.retrieveImage(forKey: url, options: nil) { result in
            switch result{
            case .success(let value):
                if let image = value.image{
                    self.image = image
                }else{
                    let storageReference = Storage.storage().reference(forURL: url)
                    storageReference.downloadURL { url, error in
                        if error != nil{
                            print("downloadUrl Error")
                            return
                        }
                        if let url = url{
                            self.kf.setImage(with: url)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
