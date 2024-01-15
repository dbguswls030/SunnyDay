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
    
    
    // MARK: User
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
    
    
    // MARK: 게시글
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
    
    func updateBoard(documentId: String, model: BoardModel, completion: @escaping () -> Void){
        let docRef = self.db.collection("community").document(documentId)
        docRef.updateData(["category" : model.category, "contents" : model.contents, "title" : model.title,
                           "contentImageURLs" : model.contentImageURLs]) { error in
            if let error = error{
                print("falied updateBoard \(error.localizedDescription)")
                FirebaseStorageManager.shared.deleteBoardContentImages(boardId: model.boardId, uid: model.uid)
                return
            }
            completion()
        }
    }
    
    func getBoard(documentId: String, completion: @escaping (BoardModel) -> Void){
        let docRef = self.db.collection("community").document(documentId)
        
        docRef.getDocument { document, error in
            if let error = error{
                print("falied getBoard \(error.localizedDescription)")
                return
            }
            guard let document = document else {
                print("documnet is not exist")
                return
            }
            var model: BoardModel
            do{
                model = try document.data(as: BoardModel.self)
            }catch let error{
                print("falied convert document to Data \(error.localizedDescription)")
                return
            }
            completion(model)
        }
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
            
            completion(models, self.db.collection("community").whereField("isDelete", isEqualTo: false).order(by: "date", descending: true).limit(to: 10).start(afterDocument: lastShapshot))
            listener?.remove()
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
    
    // MARK: 게시글 좋아요
    func checkLikeBoard(documentId: String, userId: String, completion: @escaping (Bool) -> Void){
        let docRef = self.db.collection("community").document(documentId).collection("likeBoard").document(userId)
        docRef.getDocument { snapshot, error in
            if let error = error{
                print("falied checkLikeBoard \(error.localizedDescription)")
                return
            }
            guard let document = snapshot else {
                print("checkLikeBoard is not exist document")
                return
            }
            
            if document.exists{
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    func likeBoard(documentId: String, userId: String, completion: @escaping () -> Void){
        let docRef = self.db.collection("community").document(documentId)
        docRef.collection("likeBoard").document(userId).setData([:])
        docRef.updateData(["likeCount" : FieldValue.increment(Int64(1))])
        completion()
    }
    
    func unLikeBoard(documentId: String, userId: String, completion: @escaping () -> Void){
        let docRef = self.db.collection("community").document(documentId)
        docRef.collection("likeBoard").document(userId).delete()
        docRef.updateData(["likeCount" : FieldValue.increment(Int64(-1))])
        completion()
    }
    
    // MARK: 게시글 댓글
    func uploadComment(documentId: String, commentModel: CommentModel, completion: @escaping () -> Void){
        let commentId = UUID().uuidString + String(Date().timeIntervalSince1970)
        let docRef = self.db.collection("community").document(documentId).collection("comment").document(commentId)
        do{
            try docRef.setData(from: commentModel)
            self.db.collection("community").document(documentId).updateData(["commentCount" : FieldValue.increment(Int64(1))])
            if commentModel.dept == 1{
                self.updateIsEmptyReplyForFalseInComment(documentId: documentId, parentId: commentModel.parentId) {
                    completion()
                }
            }else{
                completion()
            }
        }catch let error{
            print("failed uploadComment \(error.localizedDescription)")
            return
        }
    }
    
    func getComments(query: Query?, documentId: String, completion: @escaping ([CommentModel], Query?) -> Void){
        let request: Query
        if let query = query{
            request = query
        }else{
            // isHidden이 false 이거나, isHidden이 true이고 isEmptyReply가 false인 것들을 보여준다
            request = self.db.collection("community").document(documentId).collection("comment").whereFilter(Filter.orFilter(
                [Filter.whereField("isHidden", isEqualTo: false),
                 Filter.andFilter([Filter.whereField("isHidden", isEqualTo: true), Filter.whereField("isEmptyReply", isEqualTo: false)])])).order(by: "parentId", descending: false).order(by: "dept", descending: false).order(by: "date", descending: false).limit(to: 10)
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
            completion(models, self.db.collection("community").document(documentId).collection("comment").whereFilter(Filter.orFilter(
                [Filter.whereField("isHidden", isEqualTo: false),
                 Filter.andFilter([Filter.whereField("isHidden", isEqualTo: true), Filter.whereField("isEmptyReply", isEqualTo: false)])])).order(by: "parentId", descending: false).order(by: "dept", descending: false).order(by: "date", descending: false).limit(to: 10).start(afterDocument: lastShapshot))
        }
    }
    
    func getComment(boardDocumentId: String, commentDocumentId: String, completion: @escaping (CommentModel) -> Void){
        let docRef = self.db.collection("community").document(boardDocumentId).collection("comment").document(commentDocumentId)
        docRef.getDocument { snapshot, error in
            if let error = error {
                print("failed getComment \(error.localizedDescription)")
                return
            }
            guard let document = snapshot else { return }
            var model: CommentModel
            do{
                model = try document.data(as: CommentModel.self)
                completion(model)
            }catch let error{
                print("failed getComment decode \(error.localizedDescription)")
                return
            }
        }
    }
    
    
    
    func deleteComment(boardDocumentId: String, commentDocumentId: String, completion: @escaping () -> Void){
        let docRef = self.db.collection("community").document(boardDocumentId).collection("comment").document(commentDocumentId)
        docRef.updateData(["isHidden" : true]) { error in
            if let error = error {
                print("failed deleteComment error = \(error.localizedDescription)")
                return
            }
            self.db.collection("community").document(boardDocumentId).updateData(["commentCount" : FieldValue.increment(Int64(-1))]) { error in
                if let error = error{
                    print("failed decrement commentCount \(error.localizedDescription)")
                    return
                }
                completion()
            }
        }
    }
    
    func updateComment(boardDocumentId: String, commentDocumentId: String, content: String, completion: @escaping () -> Void){
        let docRef = self.db.collection("community").document(boardDocumentId).collection("comment").document(commentDocumentId)
        docRef.updateData(["content" : content]) { error in
            if let error = error{
                print("failed update Comment \(error.localizedDescription)")
                return
            }
            completion()
        }
    }
    
    
    func updateCommentThenDeleteComment(documentId: String, parentId: Int, completion: @escaping () -> Void){
        let docRef = self.db.collection("community").document(documentId).collection("comment")
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
                self.updateIsEmptyReplyForTrueInComment(documentId: documentId, parentId: parentId) {
                    completion()
                }
            }else{
                print("reply count != 0")
                completion()
            }
        }
    }
    
    func updateIsEmptyReplyForFalseInComment(documentId: String, parentId: Int, completion: @escaping () -> Void){
        let docRef = self.db.collection("community").document(documentId).collection("comment")
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
    
    func updateIsEmptyReplyForTrueInComment(documentId: String, parentId: Int, completion: @escaping () -> Void){
        let docRef = self.db.collection("community").document(documentId).collection("comment")
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
    
    // MARK: 댓글 좋아요
    
    func likeComment(boardDocumentId: String, commentDocumentId: String, userId: String,completion: @escaping () -> Void){
        let docRef = self.db.collection("community").document(boardDocumentId).collection("comment").document(commentDocumentId)
        docRef.collection("likeComment").document(userId).setData([:])
        docRef.updateData(["likeCount" : FieldValue.increment(Int64(1))])
        completion()
    }
    
    func unLikeComment(boardDocumentId: String, commentDocumentId: String, userId: String, completion: @escaping () -> Void){
        let docRef = self.db.collection("community").document(boardDocumentId).collection("comment").document(commentDocumentId)
        docRef.collection("likeComment").document(userId).delete()
        docRef.updateData(["likeCount" : FieldValue.increment(Int64(-1))])
        completion()
    }
    
    func checkLikeComment(boardDocumentId: String, commentDocumentId: String, userId: String, completion: @escaping (Bool) -> Void){
        let docRef = self.db.collection("community").document(boardDocumentId).collection("comment").document(commentDocumentId).collection("likeComment").document(userId)
        docRef.getDocument { snapshot, error in
            if let error = error{
                print("failed checkLikeComment \(error.localizedDescription)")
                return
            }
            guard let document = snapshot else {
                print("checkLikeComment is not exist")
                return
            }
            if document.exists{
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
}
