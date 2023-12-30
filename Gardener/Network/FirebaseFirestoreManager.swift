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
    
    func setUserInfo(uid: String, model: UserModel, completion: @escaping (Result<Bool, Error>) -> Void){
        let docRef = db.collection("user").document(uid)
        do{
            try docRef.setData(from: model)
            completion(.success(true))
        }catch let error{
            print("failed set User")
            completion(.failure(error))
            return
        }
    }
    
    
    func getUserInfo(uid: String, completion: @escaping (UserModel) -> Void){
        db.collection("user").document(uid).getDocument { document, error in
            if let error = error{
                print("failed getUserInfo : \(error.localizedDescription)")
                return
            }
            guard let document = document, document.exists else{ return }
            
            do{
                let model = try document.data(as: UserModel.self)
                completion(model)
            }catch let error{
                print("falied getUserInfo \(error.localizedDescription)")
                return
            }
        }
    }
    
    func uploadBoard(model: BoardModel, completion: @escaping () -> Void){
        let docRef = self.db.collection("community").document()
        do{
            try docRef.setData(from: model)
        }catch let error{
            print("falied uploadBoard \(error.localizedDescription)")
            FirebaseStorageManager.shared.deleteBoardContentImages(boardId: model.boardId, uid: model.uid)
            return
        }
        completion()
    }
    
    func getBoards(query: Query?, completion: @escaping ([BoardModel], Query) -> Void){
        let request: Query
        if let query = query{
            request = query
        }else{
            request = self.db.collection("community").whereField("isDelete", isEqualTo: false).order(by: "date", descending: true).limit(to: 10)
        }
        var listener: ListenerRegistration?
        listener = request.addSnapshotListener { snapshot, error in
            if let error = error{
                print("getBoards erorr = \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else{
                print("not exist snapshot")
                return
            }
            guard let lastShapshot = snapshot.documents.last else{
                print("getBoards not exist last document")
                listener?.remove()
                return
            }
            
            var models = [BoardModel]()
            snapshot.documents.forEach { document in
                do{
                    let model = try document.data(as: BoardModel.self)
                    models.append(model)
                }catch let error{
                    print("falied getBoards error \(error.localizedDescription)")
                    listener?.remove()
                    return
                }
            }
            listener?.remove()
            completion(models, self.db.collection("community").whereField("isDelete", isEqualTo: false).order(by: "date", descending: true).limit(to: 10).start(afterDocument: lastShapshot))
        }
        
    }
    
    func deleteBoard(documentId: String, completion: @escaping () -> Void){
        let docRef = self.db.collection("community").document(documentId)
        docRef.updateData(["isDelete" : true]) { error in
            if let error = error{
                print("falied deleteBoard \(error.localizedDescription)")
                return
            }
        }
        completion()
    }
    
    
    func getComments(query: Query?, boardId: String, completion: @escaping ([CommentModel], Query?) -> Void){
        let request: Query
        if let query = query{
            request = query
        }else{
            // isHidden이 false 이거나, isHidden이 true이고 isEmptyReply가 false인 것들을 보여준다
            request = self.db.collection("comments").document("\(boardId)").collection("comment").whereFilter(Filter.orFilter(
                [Filter.whereField("isHidden", isEqualTo: false),
                 Filter.andFilter([Filter.whereField("isHidden", isEqualTo: true), Filter.whereField("isEmptyReply", isEqualTo: false)])])).order(by: "parentId", descending: false).order(by: "dept", descending: false).order(by: "date", descending: false).limit(to: 20)
        }
        var listener: ListenerRegistration?
        listener = request.addSnapshotListener { snapshot, error in
            if let error = error{
                print("getComment erorr = \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else{
                print("not exist snapshot")
                return
            }
            
            guard let lastShapshot = snapshot.documents.last else{
                print("not exist lastShapshot")
                listener?.remove()
                completion([],nil)
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
                    print("failed GetComments")
                    listener?.remove()
                    return
                }
            }
            listener?.remove()
            completion(models, self.db.collection("comments").document("\(boardId)").collection("comment").whereFilter(Filter.orFilter(
                [Filter.whereField("isHidden", isEqualTo: false),
                 Filter.andFilter([Filter.whereField("isHidden", isEqualTo: true), Filter.whereField("isEmptyReply", isEqualTo: false)])])).order(by: "parentId", descending: false).order(by: "dept", descending: false).order(by: "date", descending: false).limit(to: 20).start(afterDocument: lastShapshot))
        }
    }
    
    func uploadComment(boardId: String, commentModel: CommentModel, completion: @escaping () -> Void){
        let commentId = UUID().uuidString + String(Date().timeIntervalSince1970)

        let docRef = self.db.collection("comments").document(boardId).collection("comment").document(commentId)
        do{
            try docRef.setData(from: commentModel)
            if commentModel.dept == 1{
                self.updateIsEmptyReplyForFalseInComment(boardId: boardId, parentId: commentModel.parentId) {
                    completion()
                }
            }else{
                completion()
            }
        }catch{
            print("failed uploadComment")
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
    
    func updateCommentThenDeleteComment(boardId: String, parentId: Int, completion: @escaping () -> Void){
        let docRef = self.db.collection("comments").document(boardId).collection("comment")
        // commentId이 같고 dept가 1인 것 중에 isHidden이 false인 갯수가 0일 때
        docRef.whereField("parentId", isEqualTo: parentId).whereField("dept", isEqualTo: 1).whereField("isHidden", isEqualTo: false).count.getAggregation(source: .server) { [weak self] snapshot, error in
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
                // TODO: parentId가 같고 dept가 0인 거에 isEmptyReply를 true
                self.updateIsEmptyReplyForTrueInComment(boardId: boardId, parentId: parentId) {
                    completion()
                }
            }else{
                print("reply count != 0")
                completion()
            }
        }
    }
    
    func updateIsEmptyReplyForFalseInComment(boardId: String, parentId: Int, completion: @escaping () -> Void){
        let docRef = self.db.collection("comments").document(boardId).collection("comment")
        docRef.whereField("parentId", isEqualTo: parentId).whereField("dept", isEqualTo: 0).getDocuments { snapshot, error in
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
    
    func updateIsEmptyReplyForTrueInComment(boardId: String, parentId: Int, completion: @escaping () -> Void){
        let docRef = self.db.collection("comments").document(boardId).collection("comment")
        docRef.whereField("parentId", isEqualTo: parentId).whereField("dept", isEqualTo: 0).getDocuments { snapshot, error in
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
