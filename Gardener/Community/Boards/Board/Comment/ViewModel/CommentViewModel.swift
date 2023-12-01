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
            self.comments += models
            
            comments.forEach { model in
                print(model.content)
            }
            
            completion()
        }
    }
    
}
