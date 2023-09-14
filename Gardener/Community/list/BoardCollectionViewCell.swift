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
    }
    
    func setContents(contents: String){
        boardCellView.contents.text = contents
    }
    
    func getHeight() -> CGFloat{
        return boardCellView.getCategoryHeight() + boardCellView.getContentsHeight()
    }
}
