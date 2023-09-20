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
    
    func setBoards(completion: @escaping () -> Void){
        FirebaseFirestoreManager.getCommunityBoards(query: self.query) { [weak self] models, query in
            guard let self = self else{
                return
            }
            self.boards = models
            self.query = query
            completion()
        }
    }
    
    func numberOfBoards() -> Int{
        return boards.count
    }
    
    func getTitle(index: Int) -> String{
        return boards[index].title
    }
    
    func getCategroy(index: Int) -> String{
        return boards[index].category
    }
    
    func getContents(index: Int) -> String{
        return boards[index].contents
    }
    
    func getDate(index: Int) -> Date{
        return boards[index].date
    }
}
