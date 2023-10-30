//
//  FirebaseManager.swift
//  Gardener
//
//  Created by 유현진 on 2023/08/12.
//

import Foundation
import FirebaseStorage

class FirebaseStorageManager{
    static func uploadProfileImage(image: UIImage, pathRoot: String, completion: @escaping (URL?) -> Void){
        // Warning: 용량 제한
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            print("[uploadProfileImage] failed convert image to imageData")
            return
        }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        
        let imageName = UUID().uuidString + String(Date().timeIntervalSince1970)
        let firebaseReference = Storage.storage().reference().child("\(pathRoot)").child("profileImage").child("\(imageName)")
        firebaseReference.putData(imageData, metadata: metaData) { metaData, error in
            if let error = error{
                print("putdata Error\(error.localizedDescription)")
            }
            firebaseReference.downloadURL { url, _ in
                completion(url)
            }
        }
    }
    
    static func downloadBoardImage(url: String, completion: @escaping (UIImage) -> Void){
        var images = UIImage()
        // Warning: 용량 제한
        let megaBtye = Int64(1 * 3840 * 2160)
  
        let storageReference = Storage.storage().reference(forURL: url)
        storageReference.getData(maxSize: megaBtye) { data, error in
            if let error = error{
                print("download Board Images error : \(error.localizedDescription)")
                return
            }
            guard let imageData = data else{
                print("nil data")
                return
            }
            completion(UIImage(data: imageData)!)
        }
    }
    
    static func uploadBoardImages(images: [UIImage], boardId: String, uid: String, completion: @escaping ([String]) -> Void){
        if images.isEmpty{
            completion([])
            return
        }
        var imagesData = [Data]()
        images.forEach { image in
            guard let data = image.jpegData(compressionQuality: 1) else{
                return
            }
            imagesData.append(data)
        }
        
        // url 다 채워지고 completion 되어야함
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        

        let firebaseReference = Storage.storage().reference().child("\(uid)").child("community").child("\(boardId)")
        var urls = [String]()
        
        let group = DispatchGroup()
        
        for (offset, datum) in imagesData.enumerated() {
            group.enter()
            let imagesReferce = firebaseReference.child("\(boardId)_\(offset)")
            imagesReferce.putData(datum, metadata: metaData) { metaData, error in
                if let error = error{
                    print("putdata Error\(error.localizedDescription)")
                    group.leave()
                }
                imagesReferce.downloadURL { url, _ in
                    defer{
                        group.leave()
                    }
                    if let url = url{
                        urls.append(url.absoluteString)
                    }
                }
            }
        }
        group.notify(queue: .main){
            if urls.count == imagesData.count{
                completion(urls)
            }
        }
    }
    
    static func deleteBoard(boardId: String, uid: String){
        Storage.storage().reference().child("\(uid)").child("community").child("\(boardId)").listAll { result, error in
            if error != nil{
                print("get list falied")
                return
            }
            if let result = result{
                for item in result.items{
                    item.delete { error in
                        if let error = error{
                            print("item delete failed error : \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}
