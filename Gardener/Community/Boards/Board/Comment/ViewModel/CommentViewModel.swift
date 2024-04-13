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
    private var paging = true
    private var lastPage = false
    
    func setCommentModel(documentId: String, completion: @escaping () -> Void){
        FirebaseFirestoreManager.shared.getComments(query: self.query, documentId: documentId) { [weak self] models, query in
            guard let self = self else{
                return
            }
            guard !models.isEmpty else{
                return
            }
            self.setPaging(data: false)
            self.query = query
            print(self.comments.count)
            self.comments += models
            
            if models.count < 10{
                self.setLastPage(data: true)
            }
            completion()
        }
    }
    func isValidPaging() -> Bool{
        return self.paging
    }
    
    func isLastPage() -> Bool{
        return self.lastPage
    }
    
    func setLastPage(data: Bool){
        self.lastPage = data
    }
    
    func setPaging(data: Bool){
        self.paging = data
    }
    
    func removeModel(index: Int){
        comments.remove(at: index)
    }
    
    func resetViewModel(){
        query = nil
        comments.removeAll()
        paging = true
        lastPage = false
    }
    
    func numberOfModel() -> Int{
        return comments.count
    }
    func getCommentModel(index: Int) -> CommentModel{
        return comments[index]
    }
    func getDocumentId(index: Int) -> String?{
        return comments[index].documentId
    }
    
    func getIsHiddenValue(index: Int) -> Bool{
        return comments[index].isHidden
    }
    
    func getLikeCount(index: Int) -> Int{
        return comments[index].likeCount
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
