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
        super.prepareForReuse()
        model = nil
        boardCellView.prepareReuseInitUI()
        boardCellView.imageCollectionView.gestureRecognizers = nil
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
        setImageUrl(urls: model.contentImageURLs)
        setCommentCount(commentCount: model.commentCount)
        setLikeCount(likeCount: model.likeCount)
    }
    
    private func setCategroy(categroy: String){
        boardCellView.categroy.text = categroy
    }
    
    private func setTitle(title: String){
        boardCellView.title.text = title
    }
    
    private func setContents(contents: String){
        boardCellView.contents.text = contents
    }
    
    private func setDate(date: Date){
        // TODO: 날짜 케이스, 분, 시간, 일
        boardCellView.date.text = date.convertDateToTime()
    }
    private func setCommentCount(commentCount: Int){
        if commentCount > 0{
            boardCellView.commentCountImageView.isHidden = false
            boardCellView.commentCountLabel.isHidden = false
            boardCellView.commentCountLabel.text = "\(commentCount)"
        }
    }
    private func setLikeCount(likeCount: Int){
        if likeCount > 0{
            boardCellView.likeCountImageView.isHidden = false
            boardCellView.likeCountLabel.isHidden = false
            boardCellView.likeCountLabel.text = "\(likeCount)"
        }
    }
    
    private func setImageUrl(urls: [String]){
        guard !urls.isEmpty else {
            return
        }
        initCollectionView()
    }
    
    private func initCollectionView(){
        boardCellView.imageCollectionView.register(BoardImageCollectionViewCell.self, forCellWithReuseIdentifier: "boardImageCell")
        boardCellView.imageCollectionView.dataSource = self
        boardCellView.imageCollectionView.delegate = self
        boardCellView.initImageColletionViewLayout()
    }
}

extension BoardCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = model else { return 0 }
        return model.contentImageURLs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardImageCell", for: indexPath) as? BoardImageCollectionViewCell, let model = model else {
            return UICollectionViewCell()
        }
        cell.initUI()
        cell.setImageUrl(url: model.contentImageURLs[indexPath.item])
        cell.isUserInteractionEnabled = false
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
}
