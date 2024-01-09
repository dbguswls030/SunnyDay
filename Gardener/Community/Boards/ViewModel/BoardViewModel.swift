//
//  BoardViewModel.swift
//  Gardener
//
//  Created by 유현진 on 2023/09/13.
//

import Foundation
import FirebaseFirestore

class BoardViewModel{
    private weak var query: Query? = nil
    private var boards = [BoardModel]()
    private var paging = true
    private var lastPage = false
    
    func setBoardModel(completion: @escaping () -> Void){
        FirebaseFirestoreManager.shared.getBoards(query: self.query) { [weak self] models, query in
            guard let self = self else{
                return
            }
            guard !models.isEmpty else{
                return
            }
            self.setPaging(data: false)
            self.boards += models
            self.query = query
            if models.count < 10{
                self.setLastPage(data: true)
            }
            completion()
        }
    }
    
    func setLastPage(data: Bool){
        self.lastPage = data
    }
    
    func isLastPage()->Bool{
        return self.lastPage
    }
    
    func reloadViewModel(){
        query = nil
        boards.removeAll()
        paging = true
        lastPage = false
    }
    func isValidPaging() -> Bool{
        return self.paging
    }
    func setPaging(data: Bool){
        self.paging = data
    }
    func getBoard(index: Int) -> BoardModel{
        return boards[index]
    }
    func numberOfBoards() -> Int{
        return boards.count
    }
    
    func getTitle(index: Int) -> String{
        return boards[index].title
    }
    
    func getCommentCount(index: Int) -> Int{
        return boards[index].commentCount
    }
    
    func getLikeCount(index: Int) -> Int{
        return boards[index].likeCount
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
    
    func getImageUrls(index: Int) -> [String]{
        return boards[index].contentImageURLs
    }
    
    func getHeight(index: Int, width: CGFloat) -> CGFloat{
        return 20 + getCategoryHeight(index: index, width: width) + 15 + getTitleHeight(index: index, width: width) + 10 + getContentsHeight(index: index, width: width) + 15 + getImagesHeight(index: index) + getDateHeight(index: index, width: width) + 20
    }
    func getImagesHeight(index: Int) -> CGFloat{
        return boards[index].contentImageURLs.isEmpty ? 0 : 150 + 15
    }
    func getTitleHeight(index: Int, width: CGFloat) -> CGFloat{
        let font = UIFont.systemFont(ofSize: 17, weight: .semibold) // 원하는 폰트 및 크기 선택
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: font]
        let boundingRect = (boards[index].title as NSString).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return ceil(boundingRect.height)
    }
    
    func getCategoryHeight(index: Int, width: CGFloat) -> CGFloat{
        let font = UIFont.systemFont(ofSize: 11, weight: .semibold) // 원하는 폰트 및 크기 선택
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: font]
        let boundingRect = (boards[index].category as NSString).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return ceil(boundingRect.height)
    }
    
    func getContentsHeight(index: Int, width: CGFloat) -> CGFloat{
        let font = UIFont.systemFont(ofSize: 15) // 원하는 폰트 및 크기 선택
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: font]
        let boundingRect = (boards[index].contents as NSString).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return ceil(boundingRect.height)
    }
    
    func getDateHeight(index: Int, width: CGFloat) -> CGFloat{
        let font = UIFont.systemFont(ofSize: 11) // 원하는 폰트 및 크기 선택
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: font]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.string(from: boards[index].date)
        let boundingRect = (formattedDate as NSString).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return ceil(boundingRect.height)
    }
}
