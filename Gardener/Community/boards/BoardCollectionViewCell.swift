//
//  boardCollectionViewCell.swift
//  Gardener
//
//  Created by 유현진 on 2023/08/31.
//

import UIKit
import SnapKit

class BoardCollectionViewCell: UICollectionViewCell {

    var model: BoardModel?
    
    lazy var boardCellView: BoardCellView = {
       return BoardCellView()
    }()
    
    override func prepareForReuse() {
//        super.prepareForReuse()
        model = nil
        boardCellView.prepareReuseInitUI()
//        for indexPath in boardCellView.imageCollectionView.indexPathsForVisibleItems {
//            if let cell = boardCellView.imageCollectionView.cellForItem(at: indexPath) as? BoardImageCollectionViewCell {
//                cell.imageView.image = nil
//            }
//        }
//        boardCellView.imageCollectionView.reloadData()
    }
    func initUI(){
        self.addSubview(boardCellView)
        boardCellView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    func setModel(model: BoardModel){
        self.model = model
        setCategroy(categroy: model.category)
        setTitle(title: model.title)
        setContents(contents: model.contents)
        setDate(date: model.date)
        setImageUrl(urls: model.imageUrls)
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
 
    func setImageUrl(urls: [String]){
        print(model!.title)
        guard !urls.isEmpty else {
            print("urls empty")
            return
        }
        initCollectionView()
    }
    
    func initCollectionView(){
        boardCellView.imageCollectionView.register(BoardImageCollectionViewCell.self, forCellWithReuseIdentifier: "boardImageCell")
        boardCellView.imageCollectionView.dataSource = self
        boardCellView.imageCollectionView.delegate = self
        boardCellView.initImageColletionViewLayout()
    }
}

extension BoardCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = model else { return 0 }
        return model.imageUrls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardImageCell", for: indexPath) as? BoardImageCollectionViewCell, let model = model else {
            return UICollectionViewCell()
        }
        cell.initUI()
        cell.setImageUrl(url: model.imageUrls[indexPath.item])
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
}
