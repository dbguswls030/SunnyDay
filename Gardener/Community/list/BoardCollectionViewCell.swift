//
//  boardCollectionViewCell.swift
//  Gardener
//
//  Created by 유현진 on 2023/08/31.
//

import UIKit
import SnapKit

class BoardCollectionViewCell: UICollectionViewCell {
    
    lazy var boardCellView: BoardCellView = {
       return BoardCellView()
    }()
    
    func initUI(){
        self.addSubview(boardCellView)
        boardCellView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setCategroy(categroy: String){
        boardCellView.categroy.text = categroy
        boardCellView.categroy.sizeToFit()
    }
    
    func setTitle(title: String){
        boardCellView.title.text = title
        boardCellView.title.sizeToFit()
    }
    
    func setContents(contents: String){
        boardCellView.contents.text = contents
        boardCellView.contents.sizeToFit()
    }
    
    func setDate(date: Date){
        // TODO: 날짜 케이스, 분, 시간, 일
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.string(from: date)
        boardCellView.date.text = formattedDate
        boardCellView.date.sizeToFit()
    }
    
    func getHeight() -> CGFloat{
        return boardCellView.getCategoryHeight() + boardCellView.getTitleHeight() + boardCellView.getContentsHeight() + boardCellView.getDateHeight()
    }
}
