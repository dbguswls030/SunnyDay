//
//  boardCollectionViewCell.swift
//  Gardener
//
//  Created by 유현진 on 2023/08/31.
//

import UIKit
import SnapKit

class BoardCollectionViewCell: UICollectionViewCell {

    var images: [UIImage] = []
    
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
    
    func setTitle(title: String){
        boardCellView.title.text = title
    }
    
    func setContents(contents: String){
        boardCellView.contents.text = contents
    }
    
    func setDate(date: Date){
        // TODO: 날짜 케이스, 분, 시간, 일
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.string(from: date)
        boardCellView.date.text = formattedDate
    }
 
//    func setImage(images: [UIImage]){
//        guard !images.isEmpty else {
//            boardCellView.imageCollectionView = nil
//            return
//        }
//        self.images = images
//        initCollectionView()
//        boardCellView.imageCollectionView?.reloadData()
//    }
    
//    func initCollectionView(){
//        boardCellView.imageCollectionView?.register(BoardImageCollectionViewCell.self, forCellWithReuseIdentifier: "boardImageCell")
//        boardCellView.imageCollectionView!.dataSource = self
//        boardCellView.imageCollectionView!.delegate = self
//        boardCellView.initImageColletionViewLayout()
//    }
    
//    func getHeight() -> CGFloat{
//        return boardCellView.getCategoryHeight() + boardCellView.getTitleHeight() + boardCellView.getContentsHeight() + boardCellView.getDateHeight() //+ boardCellView.getImageHeight()
//    }
}

//extension BoardCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return images.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        print("imageCellDataSource \(indexPath.item)")
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardImageCell", for: indexPath) as? BoardImageCollectionViewCell else {
//            return UICollectionViewCell()
//        }
//        cell.setImage(image: images[indexPath.item])
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        print("imageCell sizeForItem \(indexPath.item)")
//        return CGSize(width: 100, height: 100)
//    }
//}
