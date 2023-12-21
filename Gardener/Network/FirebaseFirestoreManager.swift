//
//  FirebaseStoreManager.swift
//  Gardener
//
//  Created by 유현진 on 2023/08/12.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

class FirebaseFirestoreManager{
    
    static let shared = FirebaseFirestoreManager()
    
    let db = Firestore.firestore()
    
    func getUserInfo(uid: String, completion: @escaping (UserModel) -> Void){
    
        db.collection("user").document(uid).getDocument { document, error in
            if let error = error{
                print("failed getUserInfo : \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else{ return }
            
            if let data = document.data() as? [String : Any]{
                if let nickName = data["nickName"] as? String,
                   let profileImage = data["profileImage"] as? String{
                    completion(UserModel(nickName: nickName, profileImageURL: profileImage))
                }
            }
            
        }
    }
    
    func uploadCommunityBoard(model: CreateBoard, completion: @escaping () -> Void){
        
        
        if let uid = Auth.auth().currentUser?.uid{
            let boardId = UUID().uuidString + String(Date().timeIntervalSince1970)
            FirebaseStorageManager.uploadBoardImages(images: model.images, boardId: boardId, uid: uid) { urls in
                self.db.collection("community").addDocument(data: ["category" : model.category,
                                                              "title" : model.title,
                                                              "contents" : model.contents,
                                                              "uid" : uid,
                                                              "date" : Timestamp(date: model.date),
                                                              "imageUrl" : urls,
                                                              "nickName" : model.userInfo.nickName,
                                                              "profileImage" : model.userInfo.profileImageURL]) { error in
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
    
    func getCommunityBoards(query: Query?, completion: @escaping ([BoardModel], Query) -> Void){
        
        let request: Query
        
        if let query = query{
            request = query
        }else{
            request = self.db.collection("community").order(by: "date", descending: true).limit(to: 10)
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
            
            var models = [BoardModel]()
            snapshot.documents.forEach { document in
                if let data = document.data() as? [String: Any]{
                    if let category = data["category"] as? String,
                       let title = data["title"] as? String,
                       let contents = data["contents"] as? String,
                       let date = data["date"] as? Timestamp,
                       let uid = data["uid"] as? String,
                       let imageUrls = data["imageUrl"] as? [String],
                       let boardId = document.documentID as? String,
                    let nickName = data["nickName"] as? String,
                    let profileImageURL = data["profileImage"] as? String{
                        models.append(BoardModel(category: category,
                                                 title: title,
                                                 contents: contents,
                                                 date: date.dateValue(),
                                                 imageUrls: imageUrls,
                                                 uid: uid,
                                                 boardId: boardId,
                                                 nickName: nickName,
                                                 profileImageURL: profileImageURL))
                    }
                }
            }
            completion(models, self.db.collection("community").order(by: "date", descending: true).limit(to: 10).start(afterDocument: lastShapshot))
        }
    }
    
    func getComments(query: Query?, boardId: String, completion: @escaping ([CommentModel], Query) -> Void){
        let request: Query
        
        if let query = query{
            request = query
        }else{
            // isHidden이 false 이거나, isHidden이 true이고 isEmptyReply가 false인 것들을 보여준다
            request = self.db.collection("comments").document("\(boardId)").collection("comment").whereFilter(Filter.orFilter(
                [Filter.whereField("isHidden", isEqualTo: false),
                 Filter.andFilter([Filter.whereField("isHidden", isEqualTo: true), Filter.whereField("isEmptyReply", isEqualTo: false)])])).order(by: "commentId", descending: false).order(by: "dept", descending: false).order(by: "date", descending: false).limit(to: 20)
        }

        request.addSnapshotListener { snapshot, error in
            if let error = error{
                print("getComment erorr = \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else{
                print("not exist snapshot")
                return
            }
            
            guard let lastShapshot = snapshot.documents.last else{
                return
            }
            
            var models = [CommentModel]()
            snapshot.documents.forEach { document in
                do{
                    let model = try document.data(as: CommentModel.self)
                    models.append(model)    
                }catch{
                    print("falied GetComments")
                    return
                }
            }
            completion(models, self.db.collection("comments").document("\(boardId)").collection("comment").whereFilter(Filter.orFilter(
                [Filter.whereField("isHidden", isEqualTo: false),
                 Filter.andFilter([Filter.whereField("isHidden", isEqualTo: true), Filter.whereField("isEmptyReply", isEqualTo: false)])])).order(by: "commentId", descending: false).order(by: "dept", descending: false).order(by: "date", descending: false).limit(to: 20))
        }
    }
    
    func uploadComment(boardId: String, commentModel: CommentModel, completion: @escaping () -> Void){
        
        let commentId = UUID().uuidString + String(Date().timeIntervalSince1970)
    
        
        let docRef = self.db.collection("comments").document(boardId).collection("comment").document(commentId)
        do{
            try docRef.setData(from: commentModel)   
        }catch{
            print("falied uploadComment")
            return
        }
        completion()
    }
}

//do{
//    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
//    let data = try JSONDecoder().decode(BoardModel.self, from: jsonData)
//    models.append(data)
//}catch let error{
//    print("json decoder error : \(error.localizedDescription)")
//}
