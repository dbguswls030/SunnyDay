//
//  CommentViewModel.swift
//  Gardener
//
//  Created by 유현진 on 12/2/23.
//

import Foundation
import FirebaseFirestore

class CommentViewModel{
    private var query: Query? = nil
    private var comments = [CommentModel]()

    func setViewModel(boardId: String, completion: @escaping () -> Void){
        FirebaseFirestoreManager.shared.getComments(query: self.query, boardId: boardId) { [weak self] result in
            guard let self = self else{
                return
            }
            switch result{
            case .success((let models, let query)):
                self.query = query
                self.comments = models
                print("invoke setViewModel !!")
                completion()
            case .failure(let error):
                print("error")
                completion()
                return
            }
        }
    }
    
    func resetViewModel(boardId: String, completion: @escaping () -> Void){
        FirebaseFirestoreManager.shared.getComments(query: self.query, boardId: boardId) { [weak self] result in
            guard let self = self else{
                return
            }
            switch result{
            case .success((let models, let error)):
                self.query = query
                self.comments = models
                print("invoke setViewModel !! reset")
                completion()
            case.failure(let error):
                print(error)
                completion()
                return
            }
        }
    }

    
    func removeModel(index: Int){
        comments.remove(at: index)
    }
    
    func resetViewModel(){
        print("resetViewModel")
        query = nil
        comments.removeAll()
    }
    
    func numberOfModel() -> Int{
        return comments.count
    }
    
    func getDocumentId(index: Int) -> String?{
        return comments[index].commentId
    }
    
    func getIsHiddenValue(index: Int) -> Bool{
        return comments[index].isHidden
    }
    
    func getUid(index: Int) -> String{
        return comments[index].userId
    }
    
    func getNickName(index: Int) -> String{
        return comments[index].nickName
    }
    
    func getProfileImageURL(index: Int) -> String{
        return comments[index].profileImageURL
    }
    
    func getDate(index: Int) -> Date{
        return comments[index].date
    }
    
    func getContent(index: Int) -> String{
        return comments[index].content
    }
    
    func getDept(index: Int) -> Int{
        return comments[index].dept
    }
    
    func getParentId(index: Int) -> Int{
        return comments[index].parentId
    }
}
