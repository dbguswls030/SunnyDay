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
        FirebaseFirestoreManager.getComments(query: query, boardId: boardId) { [weak self] models, query in
            guard let self = self, !models.isEmpty else{
                return
            }
            
            self.query = query
            self.comments = models
            
            completion()
            
        }
    }
    
    func resetViewModel(){
        query = nil
        comments.removeAll()
    }
    
    func numberOfModel() -> Int{
        return comments.count
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
    
    func getCommentId(index: Int) -> Int{
        return comments[index].commentId
    }
}
