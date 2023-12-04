//
//  BoardCommentView.swift
//  Gardener
//
//  Created by 유현진 on 2023/11/28.
//

import UIKit
import SnapKit

class CommentView: UIView{
    
    private lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.tintColor = .black
        label.text = "댓글"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private lazy var commentCountLabel: UILabel = {
        let label = UILabel()
        label.tintColor = .black
        label.text = "0"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    lazy var commentCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        self.backgroundColor = .white
        
        self.addSubview(commentLabel)
        self.addSubview(commentCountLabel)
        self.addSubview(commentCollectionView)
        
        commentLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        commentCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(commentLabel.snp.centerY)
            make.left.equalTo(commentLabel.snp.right).offset(5)
        }
        
        commentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(commentLabel.snp.bottom).offset(15)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func setCommentCount(count: Int){
        self.commentCountLabel.text = "\(count)"
    }
}

