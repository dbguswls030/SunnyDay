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
    
    func getComments(query: Query?, boardId: String, completion: @escaping (Result<([CommentModel], Query?), Error>) -> Void){
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
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot else{
                print("not exist snapshot")
                completion(.failure(error!))
                return
            }
            
            guard let lastShapshot = snapshot.documents.last else{
                print("not exist lastShapshot")
                completion(.success(([],nil)))
                return
            }
            
            var models = [CommentModel]()
            snapshot.documents.forEach { document in
                do{
                    var model = try document.data(as: CommentModel.self)
                    if model.isHidden == true{
                        model.nickName = "알 수 없는 사용자"
                        model.content = "삭제 된 댓글입니다."
                    }
                    models.append(model)
                }catch{
                    print("falied GetComments")
                    completion(.success(([],nil)))
                    return
                }
            }
            completion(.success((models, self.db.collection("comments").document("\(boardId)").collection("comment").whereFilter(Filter.orFilter(
                [Filter.whereField("isHidden", isEqualTo: false),
                 Filter.andFilter([Filter.whereField("isHidden", isEqualTo: true), Filter.whereField("isEmptyReply", isEqualTo: false)])])).order(by: "commentId", descending: false).order(by: "dept", descending: false).order(by: "date", descending: false).limit(to: 20).start(afterDocument: lastShapshot))))
        }
    }
    
    func uploadComment(boardId: String, commentModel: CommentModel, completion: @escaping () -> Void){
        let commentId = UUID().uuidString + String(Date().timeIntervalSince1970)

        let docRef = self.db.collection("comments").document(boardId).collection("comment").document(commentId)
        do{
            try docRef.setData(from: commentModel)
            if commentModel.dept == 1{
                self.updateIsEmptyReplyForFalseInComment(boardId: boardId, commentId: commentModel.commentId) {
                    completion()
                }
            }else{
                completion()
            }
        }catch{
            print("falied uploadComment")
            return
        }
    }
    
    func deleteComment(boardId: String, documentId: String, completion: @escaping () -> Void){
        let docRef = self.db.collection("comments").document(boardId).collection("comment").document(documentId)
        docRef.updateData(["isHidden" : true]) { error in
            if let error = error {
                print("failed deleteComment error = \(error.localizedDescription)")
            }
            completion()
        }
        
    }
    
    func updateCommentThenDeleteComment(boardId: String, commentId: Int, completion: @escaping () -> Void){
        let docRef = self.db.collection("comments").document(boardId).collection("comment")
        // commentId이 같고 dept가 1인 것 중에 isHidden이 false인 갯수가 0일 때
        docRef.whereField("commentId", isEqualTo: commentId).whereField("dept", isEqualTo: 1).whereField("isHidden", isEqualTo: false).count.getAggregation(source: .server) { [weak self] snapshot, error in
            guard let self = self else {return}
            if let error = error{
                print("updateCommentThenDeleteComment erorr = \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else{
                print("updateCommentThenDeleteComment not exist snapshot")
                return
            }
            
            if snapshot.count == 0{
                print("reply count == 0")
                // TODO: commentId가 같고 dept가 0인 거에 isEmptyReply를 true
                self.updateIsEmptyReplyForTrueInComment(boardId: boardId, commentId: commentId) {
                    completion()
                }
            }else{
                print("reply count != 0")
                completion()
            }
        }
    }
    
    func updateIsEmptyReplyForFalseInComment(boardId: String, commentId: Int, completion: @escaping () -> Void){
        let docRef = self.db.collection("comments").document(boardId).collection("comment")
        docRef.whereField("commentId", isEqualTo: commentId).whereField("dept", isEqualTo: 0).getDocuments { snapshot, error in
            if let error = error{
                print("updateIsEmptyReplyForFalseInComment erorr = \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else{
                print("updateIsEmptyReplyForFalseInComment not exist snapshot")
                return
            }
            for document in snapshot.documents{
                document.reference.updateData(["isEmptyReply" : false])
            }
            completion()
        }
    }
    
    func updateIsEmptyReplyForTrueInComment(boardId: String, commentId: Int, completion: @escaping () -> Void){
        let docRef = self.db.collection("comments").document(boardId).collection("comment")
        docRef.whereField("commentId", isEqualTo: commentId).whereField("dept", isEqualTo: 0).getDocuments { snapshot, error in
            if let error = error{
                print("updateIsEmptyReplyForTrueInComment erorr = \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else{
                print("updateIsEmptyReplyForTrueInComment not exist snapshot")
                return
            }
            for document in snapshot.documents{
                document.reference.updateData(["isEmptyReply" : true])
            }
            print("before completion updateIsEmptyReplyForTrueInComment")
            completion()
        }
    }
}

//do{
//    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
//    let data = try JSONDecoder().decode(BoardModel.self, from: jsonData)
//    models.append(data)
//}catch let error{
//    print("json decoder error : \(error.localizedDescription)")
//}
