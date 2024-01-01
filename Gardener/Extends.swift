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
    func setImageView(url: String){
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

extension UIImage{
    func setImage(url: String, completion: @escaping (UIImage?) -> Void){
        DispatchQueue.global().async {
            let url = URL(string: url)
            do{
                let data = try Data(contentsOf: url!)
                DispatchQueue.main.async {
                    completion(UIImage(data: data))
                }
            }catch let error{
                print(error.localizedDescription)
                return
            }
        }
    }
}
