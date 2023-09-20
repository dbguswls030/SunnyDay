//
//  FirebaseStoreManager.swift
//  Gardener
//
//  Created by 유현진 on 2023/08/12.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseFirestoreManager{
    static func uploadCommunityBoard(model: CreateBoard, completion: @escaping () -> Void){
        let db = Firestore.firestore()
        
        if let uid = Auth.auth().currentUser?.uid{
            let boardId = UUID().uuidString + String(Date().timeIntervalSince1970)
            FirebaseStorageManager.uploadBoardImages(images: model.images, boardId: boardId, uid: uid) { urls in
                db.collection("community").addDocument(data: ["category" : model.category,
                                                              "title" : model.title,
                                                              "contents" : model.contents,
                                                              "uid" : uid,
                                                              "date" : Timestamp(date: model.date),
                                                              "imageUrl" : urls]) { error in
                    if error != nil {
                        FirebaseStorageManager.deleteBoard(boardId: boardId, uid: uid)
//                        Toast().showToast(view: self.view, message: "게시글 업로드를 실패했습니다.")
                        return
                    }else{
//                        Toast().showToast(view: self.view, message: "게시글 업로드를 성공하였습니다.")
                        completion()
                    }
                }
            }
        }
    }
    
    static func getCommunityBoards(query: Query?, completion: @escaping ([BoardModel], Query) -> Void){
        let db = Firestore.firestore()
        let request: Query
        
        if let query = query{
            request = query
        }else{
            request = db.collection("community").order(by: "date", descending: true).limit(to: 10)
        }

        request.addSnapshotListener { snapshot, error in
            if let error = error{
                print("getCommunity erorr = \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else{
                print("not exist snapshot")
                return
            }
            guard let lastShapshot = snapshot.documents.last else{
                return
            }
            let group = DispatchGroup()
            var models = [BoardModel]()
            snapshot.documents.forEach { document in
                group.enter()
                if let data = document.data() as? [String: Any]{
                    if let category = data["category"] as? String,
                       let title = data["title"] as? String,
                       let contents = data["contents"] as? String,
                       let date = data["date"] as? Timestamp,
                       let uid = data["uid"] as? String,
                       let imageUrl = data["imageUrl"] as? [String]{
                        FirebaseStorageManager.downloadBoardImages(urls: imageUrl) { images in
                            print("downlaodBoradImage completion images -> \(images)")
                            models.append(BoardModel(category: category,
                                                     title: title,
                                                     contents: contents,
                                                     date: date.dateValue(),
                                                     images: images,
                                                     uid: uid))
                            
                        }
                        group.leave()
                    }
                }
                //                do{
//                    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
//                    let data = try JSONDecoder().decode(BoardModel.self, from: jsonData)
//                    models.append(data)
//                }catch let error{
//                    print("json decoder error : \(error.localizedDescription)")
//                }
            }
            group.notify(queue: .main){
                if models.count == snapshot.documents.count{
                    completion(models, db.collection("community").order(by: "date", descending: true).limit(to: 10).start(afterDocument: lastShapshot))
                }
            }
        }
    }
}
