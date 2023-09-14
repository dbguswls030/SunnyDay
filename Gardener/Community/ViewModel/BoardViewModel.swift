//
//  BoardViewModel.swift
//  Gardener
//
//  Created by 유현진 on 2023/09/13.
//

import Foundation
import FirebaseFirestore

class BoardViewModel{
    private var query: Query? = nil
    private var boards = [BoardModel]()
    
    func setBoards(){
        FirebaseFirestoreManager.getCommunityBoards(query: self.query) { [weak self] models, query in
            guard let self = self else{
                return
            }
            self.boards = models
            self.query = query
            print(boards)
        }
    }
    
    func numberOfBoards() -> Int{
        return boards.count
    }
}
