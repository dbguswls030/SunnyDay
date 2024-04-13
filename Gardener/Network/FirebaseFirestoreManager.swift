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
import RxSwift

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
    
    func getUserInfoWithRx(uid: String) -> Observable<UserModel>{
        return Observable.create(){ emitter in
            self.db.collection("user").document(uid).getDocument { document, error in
                if let error = error{
                    emitter.onError(error)
                }
                
                guard let document = document, document.exists else { return }
                
                do {
                    let model = try document.data(as: UserModel.self)
                    emitter.onNext(model)
                    emitter.onCompleted()
                }catch let error{
                    print("falied getUserInfo \(error.localizedDescription)")
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    
    // MARK: 유저가 참여한 채팅방 추가
    func userEnteredChatRoom(uid: String, chatRoomId: String) -> Observable<Void>{
        return Observable.create(){ emitter in
            self.db.collection("user").document(uid)
                .collection("chat").document(chatRoomId).setData([:]) { error in
                if let error = error{
                    print("failed userEnteredChatRoom \(error.localizedDescription)")
                    emitter.onError(error)
                }
                emitter.onNext(())
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    
    // MARK: 채팅방 나가기
    func userExitedChatRoom(uid: String, chatRoomId: String) -> Observable<Void>{
        return Observable.create(){ emitter in
            self.db.collection("user").document(uid)
                .collection("chat").document(chatRoomId).delete() { error in
                if let error = error{
                    print("failed userExitedChatRoom \(error.localizedDescription)")
                    emitter.onError(error)
                }
                emitter.onNext(())
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    
    // MARK: 유저가 참여한 채팅방 Id 가져오기
    func addListenerParticipatedChatRoomId(uid: String) -> Observable<[String]>{
        return Observable.create { emitter in
            self.db.collection("user").document(uid).collection("chat").addSnapshotListener { snapshot, error in
                if let error = error{
                    emitter.onError(error)
                }
                guard let documents = snapshot?.documents else {
                    print("getParticipatedChatRoom no exist documents")
                    return
                }
                var chatRoomIdList = [String]()
                documents.forEach { document in
                    chatRoomIdList.append(document.documentID)
                }
                emitter.onNext(chatRoomIdList)
            }
            return Disposables.create()
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
    
    
    // MARK: 채팅
    
    // MARK: 채팅방 만들기
    func createChatRoomWithRx(model: ChatRoomModel) -> Observable<ChatRoomModel>{
        return Observable.create { emitter in
            do{
                try self.db.collection("chat").document(model.roomId).setData(from: model)
                emitter.onNext(model)
                emitter.onCompleted()
            }catch let error{
                emitter.onError(error)
            }
            return Disposables.create()
        }
    }
    
    // MARK: 채팅방 정보 수정
    func updateChatRoom(chatRoomId: String, title: String, subTitle: String) -> Observable<Void>{
        return Observable.create{ emitter in
            self.db.collection("chat").document(chatRoomId)
                .updateData(["title" : title,
                             "subTitle" : subTitle]) { error in
                    if let error = error{
                        emitter.onError(error)
                    }
                    emitter.onNext(())
                    emitter.onCompleted()
                }
            return Disposables.create()
        }
    }
    
    // MARK: 채팅방 나가기 -> 채팅방 멤버 삭제
    func exitChatRoom(roomId: String, uid: String) -> Observable<Void>{
        return Observable.create{ emitter in
            
            let docRef = self.db.collection("chat").document(roomId)
            docRef.collection("members").document(uid).delete { error in
                if let error = error{
                    emitter.onError(error)
                }
                self.db.collection("chat").document(roomId).updateData(["memberCount" : FieldValue.increment(Int64(-1))])
                emitter.onNext(())
                emitter.onCompleted()
            }

            return Disposables.create()
        }
    }
    
    // MARK: 채팅방 인원 추가
    func addChatRoomMember(chatRoomId: String, member: ChatMemberModel) -> Observable<Void>{
        return Observable.create{ emitter in
            do {
                try self.db.collection("chat").document(chatRoomId).collection("members").document(member.uid!).setData(from: member)
                self.db.collection("chat").document(chatRoomId).updateData(["memberCount" : FieldValue.increment(Int64(1))])
                emitter.onNext(())
                emitter.onCompleted()
            }catch let error{
                emitter.onError(error)
            }
            return Disposables.create()
        }
    }
    
    // MARK: 채팅방 인원 찾기
    func getChatMember(chatRoomId: String, uid: String) -> Observable<ChatMemberModel>{
        return Observable.create{ emitter in
            self.db.collection("chat").document(chatRoomId).collection("members").document(uid)
                .getDocument { snapshot, error in
                    if let error = error{
                        emitter.onError(error)
                    }
                    guard let document = snapshot, document.exists else {
                        emitter.onCompleted()
                        return
                    }
                    do{
                        let model = try document.data(as: ChatMemberModel.self)
                        emitter.onNext(model)
                        emitter.onCompleted()
                    }catch let error{
                        emitter.onError(error)
                    }
                }
            return Disposables.create()
        }
    }
    // MARK: 채팅방 인원 수 리스너
    func addListenerChatMemberCount(chatRoomId: String) -> Observable<Void>{
        return Observable.create { emitter in
            self.db.collection("chat").document(chatRoomId).collection("members")
                .addSnapshotListener { snapshot, error in
                    if let error = error { emitter.onError(error) }
                    
                    guard let changes = snapshot?.documentChanges else {
                        emitter.onCompleted()
                        return
                    }
                    
                    if changes.contains(where: { $0.type == .added || $0.type == .removed }){
                        emitter.onNext(())
                    } 
            }
            return Disposables.create()
        }
    }
    // MARK: 채팅방 인원 가져오기
    func getChatMembers(chatRoomId: String) -> Observable<[ChatMemberModel]>{
        return Observable.create{ emitter in
            self.db.collection("chat").document(chatRoomId).collection("members")
                .getDocuments { snapshot, error in
                    if let error = error {
                        emitter.onError(error)
                    }
                    
                    guard let document = snapshot?.documents else{
                        emitter.onCompleted()
                        return
                    }
                    
                    let members = document.compactMap { document in
                        return try? document.data(as: ChatMemberModel.self)
                    }
                    emitter.onNext(members)
            }
            return Disposables.create()
        }
    }
    
    
    // MARK: 채팅방 섬네일 수정
    func updateChatRoomThumbnail(chatRoomId: String, thumbailURL: String) -> Observable<Void>{
        return Observable.create { emitter in
            self.db.collection("chat").document(chatRoomId).updateData(["thumbnailURL" : thumbailURL]) { error in
                if let error = error {
                    emitter.onError(error)
                }
                emitter.onNext(())
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    
    // MARK: 채팅방Id로 채팅방 가져오기
    func getChatRoomWithChatRoomId(chatRoomIdList: [String]) -> Observable<[ChatRoomModel]>{
        return Observable.create{ emitter in
            if chatRoomIdList.isEmpty {
                emitter.onNext([])
                emitter.onCompleted()
            }else{
                self.db.collection("chat").whereField(FieldPath.documentID(), in: chatRoomIdList)
                    .getDocuments { snapshot, error in
                        if let error = error{
                            emitter.onError(error)
                        }
                        guard let documents = snapshot?.documents else{
                            emitter.onNext([])
                            emitter.onCompleted()
                            return
                        }
                        
                        let chatRoomList = documents.compactMap{ document in
                            return try? document.data(as: ChatRoomModel.self)
                        }
                        
                        emitter.onNext(chatRoomList)
                        emitter.onCompleted()
                    }
            }
            return Disposables.create()
        }
    }
    
    
    // MARK: 메시지 전송
    func sendChatMessage(chatRoomId: String, message: ChatMessageModel) -> Observable<Void>{
        return Observable.create{ emitter in
            do{
                try self.db.collection("chat").document(chatRoomId).collection("messages").document()
                    .setData(from: message)
                emitter.onNext(())
                emitter.onCompleted()
            }catch let error{
                emitter.onError(error)
            }
            return Disposables.create()
        }
    }
    
    // MARK: 채팅방 리스너
    func addListenerChatRoom(chatRoomId: String) -> Observable<ChatRoomModel>{
        return Observable.create { emitter in
            let docRef = self.db.collection("chat").document(chatRoomId)
            docRef.addSnapshotListener { snapshot, error in
                if let error = error{
                    emitter.onError(error)
                }
                guard let document = snapshot else { return }
                
                do{
                    try emitter.onNext(document.data(as: ChatRoomModel.self))
                }catch let error{
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    // MARK: 채팅방 입장 시 메시지 가져오기
    func getFirstChatMessages(chatRoomId: String, firstVisitedDate: Timestamp) -> Observable<([ChatMessageModel],Query)>{
        return Observable.create { emitter in
            let docRef = self.db.collection("chat").document(chatRoomId).collection("messages")
                .whereFilter(Filter.andFilter(
                    [Filter.whereField("date", isGreaterThan: firstVisitedDate),
                     Filter.whereField("isExpelled", isEqualTo: false)]))
                .order(by: "date", descending: true)
                .limit(to: 30)
            
            docRef.getDocuments { snapshot, error in
                if let error = error{
                    emitter.onError(error)
                }
                guard let documents = snapshot?.documents else { return }
                guard let lastDocuments = documents.last else { return }
                let messages = documents.compactMap { document in
                    return try? document.data(as: ChatMessageModel.self)
                }
                emitter.onNext((messages.reversed(), docRef.start(afterDocument: lastDocuments)))
                emitter.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    // MARK: 메시지 리스너
    func addListenerChatMessage(chatRoomId: String) -> Observable<[ChatMessageModel]>{
        return Observable.create{ emitter in
            let docRef = self.db.collection("chat").document(chatRoomId).collection("messages").order(by: "date", descending: false)
            docRef.addSnapshotListener { snapshot, error in
                if let error = error{
                    emitter.onError(error)
                }
                guard let documents = snapshot?.documentChanges else { return }
                
                let message = documents.compactMap { change -> ChatMessageModel? in
                    guard change.type == .added else { return nil }
                    return try? change.document.data(as: ChatMessageModel.self)
                }
                emitter.onNext(message)
            }
            return Disposables.create()
        }
    }
    
    // MARK: 이전 메시지 가져오기
    func getPreviousMessages(query: Query, chatRoomId: String) -> Observable<([ChatMessageModel], Query)>{
        return Observable.create{ emitter in
            let docRef = query.limit(to: 60)
            docRef.getDocuments { snapshot, error in
                if let error = error{
                    emitter.onError(error)
                }
                guard let documents = snapshot?.documents else{
                    emitter.onCompleted()
                    return
                }
                guard let lastDocument = documents.last else { return }
                let messages = documents.compactMap{
                    return try? $0.data(as: ChatMessageModel.self)
                }
                emitter.onNext((messages.reversed(), docRef.start(afterDocument: lastDocument)))
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    // MARK: 채팅방 좋아요
    func likeChatRoom(chatRoomId: String, uid: String) -> Observable<Void>{
        return Observable.create{ emitter in
            self.db.collection("chat").document(chatRoomId).collection("like").document(uid).setData([:]) { error in
                if let error = error{
                    emitter.onError(error)
                }
                self.db.collection("chat").document(chatRoomId).updateData(["likeCount" : FieldValue.increment(Int64(1))]) { error in
                    if let error = error{
                        emitter.onError(error)
                    }
                    emitter.onNext(())
                    emitter.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    // MAKR: 채팅방 좋아요 취소
    func unLikeChatRoom(chatRoomId: String, uid: String) -> Observable<Void>{
        return Observable.create{ emitter in
            self.db.collection("chat").document(chatRoomId).collection("like").document(uid).delete() { error in
                if let error = error{
                    emitter.onError(error)
                }
                self.db.collection("chat").document(chatRoomId).updateData(["likeCount" : FieldValue.increment(Int64(-1))]) { error in
                    if let error = error{
                        emitter.onError(error)
                    }
                    emitter.onNext(())
                    emitter.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    // MARK: 채팅방 좋아요 유무 찾기
    func isLikeChatRoom(chatRoomId: String, uid: String) -> Observable<Bool>{
        return Observable.create{ emitter in
            self.db.collection("chat").document(chatRoomId).collection("like").document(uid)
                .getDocument { snapshot, error in
                    if let error = error{
                        emitter.onError(error)
                    }
                    
                    guard let document = snapshot, document.exists else {
                        emitter.onNext(false)
                        emitter.onCompleted()
                        return
                    }
                    
                    emitter.onNext(true)
                    emitter.onCompleted()
                }
            return Disposables.create()
        }
    }
    
    // MARK: 채팅방 검색
    func searchChatRoomList(keyword: String) -> Observable<[ChatRoomModel]>{
        return Observable.create{ emitter in
            self.db.collection("chat")
            return Disposables.create()
        }
    }
    
    // MARK: 채팅방 추방 리스너(채팅 멤버에 내가 없으면 방 나가짐)
    func addListenerExpulsionChat(chatRoomId: String) -> Observable<Void>{
        return Observable.create{ emitter in
             self.db.collection("chat").document(chatRoomId).collection("members").whereField(FieldPath.documentID(), in: [Auth.auth().currentUser!.uid]).addSnapshotListener { snapshot, error in
                if let error = error{
                    emitter.onError(error)
                }
                 
                guard let documents = snapshot?.documentChanges else{
                    return
                }
                documents.forEach { change in
                    if change.type == .removed {
                        emitter.onNext(())
                        emitter.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    // MARK: 채팅방에서 나의 권한
    func WhoAreYouAtChatRoom(chatRoomId: String, uid: String) -> Observable<Int>{
        return Observable.create { emitter in
            self.db.collection("chat").document(chatRoomId).collection("members").document(uid).getDocument { snapshot, error in
                if let error = error{
                    emitter.onError(error)
                }
                
                guard let document = snapshot else{
                    return
                }
                if let level = document.data()?["level"] as? Int{
                    emitter.onNext(level)
                    emitter.onCompleted()
                }

            }
            return Disposables.create()
        }
    }
    
    
    // MARK: 채팅방 입장 시 최근 입장 시간 갱신
    func updateVisitedDate(chatRoomId: String) -> Observable<Void>{
        return Observable.create{ emitter in
            
            self.db.collection("chat").document(chatRoomId).collection("members").document(Auth.auth().currentUser!.uid).getDocument { snapshot, error in
                if let error = error{
                    emitter.onError(error)
                }
                
                guard let document = snapshot, document.exists else{
                    emitter.onCompleted()
                    return
                }
                document.reference.updateData(["updateVisitedDate" : Date()]) { error in
                    if let error = error{
                        emitter.onError(error)
                    }
                    emitter.onNext(())
                    emitter.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    func getFirstVisitedDate(chatRoomId: String) -> Observable<Timestamp>{
        return Observable.create{ emitter in
            self.db.collection("chat").document(chatRoomId).collection("members").document(Auth.auth().currentUser!.uid).getDocument { snapshot, error in
                if let error = error{
                    emitter.onError(error)
                }
                guard let document = snapshot else{
                    return
                }
                if let firstVisitedDate = document.data()?["firstVisitedDate"] as? Timestamp{
                    emitter.onNext(firstVisitedDate)
                    emitter.onCompleted()
                }else{
                    emitter.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
  
    // MARK: 추방당한 유저 메시지 isExpelled 필드 변경
    func updateExpelledUserMessage(chatRoomId: String, uid: String) -> Observable<Void>{
        return Observable.create{ emitter in
            self.db.collection("chat").document(chatRoomId).collection("messages").whereField("uid", isEqualTo: uid)
                .getDocuments { snapshot, error in
                    if let error = error{
                        emitter.onError(error)
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    documents.forEach { document in
                        document.reference.updateData(["isExpelled" : true])
                    }
                    emitter.onNext(())
                    emitter.onCompleted()
                }
            return Disposables.create()
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func addChatBlockMember(chatRoomId: String, myUid: String, blockUid: String) -> Observable<Void>{
        return Observable.create{ emitter in
            self.db.collection("chat").document(chatRoomId).collection("members").document(myUid).collection("blockMembers").document(blockUid).setData([:]) { error in
                if let error = error{
                    emitter.onError(error)
                }
                emitter.onNext(())
                emitter.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
   
    
    
    
    
    // MARK: FireStore 수정
    
    func insertBlockMember(chatRoomId: String, uid: String) -> Observable<Void>{
        return Observable.create{ emitter in
            self.db.collection("chat").getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                documents.forEach { document in
                    document.reference.collection("members").getDocuments { subSnapshot, error in
                        guard let subDocuments = subSnapshot?.documents else { return }
                        subDocuments.forEach { subDocument in
                            subDocument.reference.collection("blockMembers")
                        }
                        
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    
    
    // MARK: 추방하고나서 하프뷰 다시 열리는 오류 수정 테스트용 멤버필드 재생성
    func reMakeMember() -> Observable<Void>{
        return Observable.create{ emitter in
            self.db.collection("user").document("7mHuOKIPBBSNeIIA3nPxOhyOkso1").collection("chat").document("57719431-4019-4E16-8C6B-D41070F34CA51712585064.94737").setData([:])
            self.db.collection("chat").document("57719431-4019-4E16-8C6B-D41070F34CA51712585064.94737").updateData(["memberCount" : FieldValue.increment(Int64(1))])
            self.db.collection("chat").document("57719431-4019-4E16-8C6B-D41070F34CA51712585064.94737")
                .collection("members").document("7mHuOKIPBBSNeIIA3nPxOhyOkso1").setData(["level" : 2,
                                                                                         "firstVisitedDate" : Timestamp(),
                                                                                         "updateVisitedDate" : Timestamp()]) { error in
                    if let error = error{
                        emitter.onError(error)
                    }
                    emitter.onNext(())
                    emitter.onCompleted()
                }
            return Disposables.create()
        }
    }
    
    // MARK: 메시지에 isExpelled 넣어주기
    private func insertIsExpelledInMessageField() -> Observable<Void>{
        return Observable.create{ emitter in
            self.db.collection("chat").getDocuments { snapshot, error in
                if let error = error{
                    emitter.onError(error)
                }
                guard let documents = snapshot?.documents else { return }
                documents.forEach { document in
                    document.reference.collection("messages").getDocuments { subSnapshot, error in
                        if let error = error{
                            emitter.onError(error)
                        }
                        guard let documents = subSnapshot?.documents else { return }
                    
                        documents.forEach { subDocument in
                            subDocument.reference.updateData(["isExpelled" : false])
                        }
                    }
                }
                emitter.onNext(())
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    
    // MARK: 채팅방 생성 일자 찾아서 채팅방 입장 멤버 두개에 넣어주기
    private func insertVistedDate() -> Observable<Void>{
        return Observable.create { emitter in
            self.db.collection("chat").getDocuments { snapshot, error in
                if let error = error{
                    emitter.onError(error)
                }
                
                guard let documents = snapshot?.documents else { return }
                
                documents.forEach { document in
                    if let date = document.data()["date"]{
                        document.reference.collection("members").getDocuments { subSnapshot, error in
                            if let error = error{
                                emitter.onError(error)
                            }
                            guard let documents = subSnapshot?.documents else { return }
                            documents.forEach { subDocument in
                                subDocument.reference.updateData(["firstVisitedDate" : date,
                                                                  "updateVisitedDate" : date])
                            }
                        }
                    }
                }
                emitter.onNext(())
                emitter.onCompleted()
                
            }
            return Disposables.create()
        }
    }
    
    
    
    
    // MARK: 채팅방 모델의 Members 필드를 하위 컬렉션으로 이동
    private func moveMembersFieldToLowerCollection() -> Observable<Void>{
        return Observable.create{ emitter in
            let docRef = self.db.collection("chat")
            docRef.getDocuments { snapshot, error in
                if let error = error{
                    emitter.onError(error)
                }
                guard let documents = snapshot?.documents else {
                    emitter.onCompleted()
                    return
                }
//                var members = [ChatMemberModel]()
                for document in documents {
                    do {
                        let model = try document.data(as: ChatRoomModel.self)
//                        model.members.forEach { memberModel in
//                            members.append(memberModel)
//                        }
                    }catch let error{
                        emitter.onError(error)
                    }
                    
//                    members.forEach { memberModel in
//                        document.reference.collection("members").document(memberModel.uid).setData(["level" : memberModel.level])
//                    }
//                    
                    emitter.onNext(())
                    emitter.onCompleted()
                }
                // members의 내용을 다 읽어서
                // members 컬렉션에 다 넣기
                
            }
            return Disposables.create()
        }
    }
    
    // MARK: chatRoomModel에  members "필드" 삭제
    private func deleteMembersFieldInChatRoomModel() -> Observable<Void>{
        return Observable.create{ emitter in
            let docRef = self.db.collection("chat")
            docRef.getDocuments { snapshot, error in
                if let error = error{
                    emitter.onError(error)
                }
                guard let documents = snapshot?.documents else {
                    emitter.onCompleted()
                    return
                }
                for document in documents {
                    document.reference.updateData(["members" : FieldValue.delete()])
                }
                emitter.onNext(())
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    // MARK: 채팅방 모델에 likeCount 필드 추가하기
    private func insertLikeCountInChatRoomModel() -> Observable<Void>{
        return Observable.create{ emitter in
            let docRef = self.db.collection("chat")
            docRef.getDocuments { snapshot, error in
                if let error = error{
                    emitter.onError(error)
                }
                guard let documents = snapshot?.documents else {
                    emitter.onCompleted()
                    return
                }
                for document in documents {
                    document.reference.updateData(["likeCount" : 0])
                }
                
                emitter.onNext(())
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    private func insertMembersCountInChatRoomModel() -> Observable<Void>{
        return Observable.create{ emitter in
            let docRef = self.db.collection("chat")
            docRef.getDocuments { snapshot, error in
                if let error = error{
                    emitter.onError(error)
                }
                guard let documents = snapshot?.documents else {
                    emitter.onCompleted()
                    return
                }
                for document in documents {
                    document.reference.updateData(["memberCount" : 0])
                }
                
                emitter.onNext(())
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
}
