//
//  BoardCommentView.swift
//  Gardener
//
//  Created by 유현진 on 2023/11/28.
//

import UIKit
import SnapKit

class CommentView: UIView{
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0.9
        label.font = .systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.text = "가장 먼저 댓글을 남겨보세요."
        return label
    }()
    private lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.text = "댓글"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private lazy var commentCountLabel: UILabel = {
        let label = UILabel()
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
        self.backgroundColor = .systemBackground
        self.addSubview(commentLabel)
        self.addSubview(commentCountLabel)
        self.addSubview(commentCollectionView)
        self.addSubview(warningLabel)
        
        warningLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
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
    
    func setLabel(count: Int){
        if count == 0{
            warningLabel.isHidden = false
        }else{
            warningLabel.isHidden = true
        }
    }
    
    func setCommentCount(count: Int){
        self.commentCountLabel.text = "\(count)"
    }
    
    func getCommentLabelHeight() -> Int{
        return Int(ceil(self.commentLabel.frame.size.height))
    }
}

